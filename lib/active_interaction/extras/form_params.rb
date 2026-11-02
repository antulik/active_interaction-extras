module ActiveInteraction::Extras::FormParams
  extend ActiveSupport::Concern

  include ActiveInteraction::Extras::StrongParams

  def form_attributes
    attributes = self.class.filters.each_with_object({}) do |(filter_name, _filter), attributes|
      attributes[filter_name] = self.send(filter_name)
    end

    ActionController::Parameters.new(attributes).permit(self.class.permitted_params)
  end

  def to_params(attributes = {})
    { to_model&.model_name&.param_key => form_attributes.merge(attributes) }
  end

  class_methods do
    def to_params(form_attributes)
      { model_name&.param_key => form_attributes }
    end
  end
end
