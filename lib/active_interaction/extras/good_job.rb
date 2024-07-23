require 'active_job'

module ActiveInteraction::Extras::GoodJob
  extend ActiveSupport::Concern
  include ActiveInteraction::Extras::ActiveJob

  module BatchJobPerform
    def perform(batch, options)
      job_klass = batch.properties[:job_klass]
      job_klass_params = batch.properties[:job_klass_params]

      ActiveInteraction::Extras::Current::CurrentContext
        .set(batch_event: options[:event]) do
        job_klass.constantize.perform_now(job_klass_params)
      end
    end
  end

  module Perform
    extend ActiveSupport::Concern
    include ActiveInteraction::Extras::ActiveJob::Perform

    def _good_job_default_concurrency_key
      Digest::MD5.base64digest([self.class.name, arguments].to_param)
    end
  end

  class_methods do
    def define_job_class(klass)
      super

      unless const_defined?(:BatchJob, false)
        const_set(:BatchJob, Class.new(job_class) do
          include BatchJobPerform
        end)
      end
    end

    def batch_job(job_klass_params)
      batch = GoodJob::Batch.new
      batch.description = self.name
      batch.on_finish = self::BatchJob.name
      batch.properties = {
        job_klass: self.job_class.name,
        job_klass_params:
      }
      batch
    end
  end

  class MyBatchCallbackJob < ApplicationJob
    def perform(batch, options)
      job_klass = batch.properties[:job_klass]
      job_klass_params = batch.properties[:job_klass_params]

      ActiveInteraction::Extras::Current::CurrentContext.set(batch_event: options[:event]) do
        job_klass.constantize.perform_now(job_klass_params)
      end
    end
  end
end
