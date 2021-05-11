require 'active_job'

module ActiveInteraction::Extras::Jobs::Sidekiq
  extend ActiveSupport::Concern

  include ActiveInteraction::Extras::Jobs::Core

  class_methods do
    def delay(options = {})
      ConfiguredJob.new(job_class, options)
    end
  end

  module Perform
    extend ActiveSupport::Concern

    class_methods do
      def deserialize_active_job_args(serialized_job)
        ActiveJob::Arguments.deserialize(serialized_job['args']).first&.with_indifferent_access || {}
      end

      def perform_later(*args)
        ConfiguredJob.new(self).perform_later(*args)
      end
    end

    def perform(*args)
      # support for sidekiq encrypted params
      if args.length > 1 && args[0].nil?
        args.shift
      end

      args = ActiveJob::Arguments.deserialize(args)
      if self.class.respond_to?(:module_parent)
        self.class.module_parent.run!(*args)
      else
        self.class.parent.run!(*args)
      end
    end

    def deserialize_active_job_args(job_arguments)
      ActiveJob::Arguments.deserialize(job_arguments).first&.with_indifferent_access || {}
    end
  end

  class ConfiguredJob < ::ActiveJob::ConfiguredJob
    def perform_now(*args)
      @job_class.run!(*args)
    end

    def perform_later(*args)
      args = ActiveJob::Arguments.serialize(args)
      scope = @job_class.set(@options.except(:wait, :wait_until))

      if @job_class.sidekiq_options['encrypt']
        args.prepend(nil)
      end

      if @options[:wait]
        scope.perform_in @options[:wait], *args
      elsif @options[:wait_until]
        scope.perform_at @options[:wait_until], *args
      else
        scope.perform_async *args
      end
    end

    alias_method :run!, :perform_later
    alias_method :run, :perform_later
  end
end
