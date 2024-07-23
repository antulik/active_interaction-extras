require 'active_job'

module ActiveInteraction::Extras::ActiveJob
  extend ActiveSupport::Concern
  include ActiveInteraction::Extras::Jobs::Core

  class_methods do
    def configured_job_class
      ConfiguredJob
    end
  end

  module Perform
    extend ActiveSupport::Concern

    def perform(*args)
      ActiveInteraction::Extras::Current::CurrentContext.set(job: self) do
        if self.class.respond_to?(:module_parent)
          self.class.module_parent.run!(*args)
        else
          self.class.parent.run!(*args)
        end
      end
    end
  end

  class ConfiguredJob < ::ActiveJob::ConfiguredJob
    def run(*args)
      perform_later(*args)
    end

    def run!(*args)
      perform_later(*args)
    end
  end
end
