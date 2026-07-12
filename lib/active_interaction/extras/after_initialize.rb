module ActiveInteraction::Extras::AfterInitialize
  extend ActiveSupport::Concern

  include ActiveSupport::Callbacks

  included do
    define_callbacks :initialize
  end

  class_methods do
    def after_initialize(...)
      set_callback(:initialize, :after, ...)
    end
  end

  def initialize(...)
    super
    run_callbacks :initialize, :after
  end
end
