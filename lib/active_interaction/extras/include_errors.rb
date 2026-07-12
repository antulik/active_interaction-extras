module ActiveInteraction::Extras::IncludeErrors
  extend ActiveSupport::Concern

  include ActiveInteraction::Extras::Halt

  def include_errors!(model, **mapping)
    errors.merge! model.errors, **mapping
    halt_if_errors!
  end
end
