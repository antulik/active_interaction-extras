module ActiveInteraction::Extras::IncludeErrors
  extend ActiveSupport::Concern

  include ActiveInteraction::Extras::Halt

  def include_errors!(model, **mapping)
    errors.merge! model.errors, **mapping
    halt_if_errors!
  end

  def include_collection_errors!(name)
    if send(name).any? { it.invalid? }
      errors.add name, :invalid
    end
    halt_if_errors!
  end
end
