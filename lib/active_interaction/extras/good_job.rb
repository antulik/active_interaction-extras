require 'active_job'

module ActiveInteraction::Extras::GoodJob
  extend ActiveSupport::Concern
  include ActiveInteraction::Extras::ActiveJob

  module BatchJobPerform
    def perform(batch, options)
      ActiveInteraction::Extras::Current::CurrentContext
        .set(batch:, batch_event: options[:event]) do
        super(batch.properties)
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

    def batch_job(job_params)
      batch = GoodJob::Batch.new
      batch.description = self.name
      batch.on_finish = self::BatchJob.name
      batch.properties = job_params
      batch
    end
  end
end
