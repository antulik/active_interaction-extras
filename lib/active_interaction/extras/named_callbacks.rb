module ActiveInteraction::Extras::NamedCallbacks
  extend ActiveSupport::Concern

  class_methods do
    def before_filter(...)
      set_callback(:filter, :before, ...)
    end

    def after_filter(...)
      set_callback(:filter, :after, ...)
    end

    def around_filter(...)
      set_callback(:filter, :around, ...)
    end


    def before_validate(...)
      set_callback(:validate, :before, ...)
    end

    def after_validate(...)
      set_callback(:validate, :after, ...)
    end

    def around_validate(...)
      set_callback(:validate, :around, ...)
    end


    def before_execute(...)
      set_callback(:execute, :before, ...)
    end

    def after_execute(...)
      set_callback(:execute, :after, ...)
    end

    def around_execute(...)
      set_callback(:execute, :around, ...)
    end
  end
end
