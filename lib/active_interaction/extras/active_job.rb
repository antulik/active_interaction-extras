require 'active_job'

module ActiveInteraction::Extras::ActiveJob
  extend ActiveSupport::Concern
  include ActiveInteraction::Extras::Jobs::Core

  class_methods do
    def configured_job_class
      ConfiguredJob
    end

    def perform_now(&block)
      job_class.perform_now(&block)
    end
  end

  module Perform
    extend ActiveSupport::Concern

    def perform(*args)
      ActiveInteraction::Extras::Current::CurrentContext.set(job: self) do
        parent_class.run!(*args)
      end
    end

    def parent_class
      if self.class.respond_to?(:module_parent)
        self.class.module_parent
      else
        self.class.parent
      end
    end

    class_methods do
      def perform_now
        Thread.current[name] ||= []
        Thread.current[name].push true
        yield
      ensure
        if Thread.current[name].size == 1
          Thread.current[name] = nil
        else
          Thread.current[name].pop
        end
      end

      def perform_now?
        Thread.current[name]
      end
    end
  end

  class ConfiguredJob < ::ActiveJob::ConfiguredJob
    def run(*args)
      run!(*args)
    end

    def run!(*args)
      if @job_class.perform_now?
        perform_now(*args)
      else
        perform_later(*args)
      end
    end
  end
end
