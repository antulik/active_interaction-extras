module ActiveInteraction::Extras::Current
  extend ActiveSupport::Concern

  class CurrentContext < ActiveSupport::CurrentAttributes
    attribute :job
    attribute :batch_event
    attribute :batch

    def batch
      super || job&.batch
    end
  end

  def current
    self.class.current
  end

  class_methods do
    def current
      CurrentContext
    end
  end
end
