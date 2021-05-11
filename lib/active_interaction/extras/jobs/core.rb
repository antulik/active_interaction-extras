module ActiveInteraction::Extras::Jobs::Core
  extend ActiveSupport::Concern

  class_methods do
    def define_job_class(klass)
      unless const_defined?(:Job, false)
        const_set(:Job, Class.new(klass))
      end
    end

    def job(&block)
      job_class.class_exec(&block)
    end

    def job_class
      const_get(:Job, false)
    end

    def inherited(subclass)
      super
      subclass.define_job_class(job_class)
    end

    def delay(options = {})
      configured_job_class.new(job_class, options)
    end

    def configured_job_class
      raise NotImplementedError
    end
  end
end
