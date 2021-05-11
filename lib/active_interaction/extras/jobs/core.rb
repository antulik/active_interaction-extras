module ActiveInteraction::Extras::Jobs::Core
  extend ActiveSupport::Concern

  class_methods do
    def define_job_class klass
      unless const_defined?(:Job, false)
        const_set(:Job, Class.new(klass))
      end
    end

    def active_job &block
      job_class.class_exec(&block)
    end
    alias_method :job, :active_job

    def job_class
      const_get(:Job, false)
    end

    def inherited(subclass)
      super
      subclass.define_job_class(job_class)
    end

    def delay(options = {})
      raise NotImplementedError
    end
  end
end
