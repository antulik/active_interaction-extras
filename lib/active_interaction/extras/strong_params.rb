module ActiveInteraction::Extras::StrongParams
  extend ActiveSupport::Concern

  def initialize(inputs = {})
    # TODO: whitelist :params and :form_params, so they could not be used as filters
    return super if
      self.class.filters.key?(:params) ||
      self.class.filters.key?(:form_params) ||
      !%i[fetch key? merge].all? { |m| inputs.respond_to? m }

    if inputs.key?(:params) && inputs.key?(:form_params)
      raise ArgumentError, 'Both options :params and :form_params are given. ' \
      'One or none are accepted.'
    end

    form_params = inputs.fetch(:form_params) do
      params = inputs[:params]
      if params
        key = to_model&.model_name&.param_key
        params.require(key) if params.respond_to?(:require) && params.key?(key)
      end
    end

    if form_params
      inputs = inputs.merge(form_params.permit(self.class.permitted_params))
    end

    super(inputs)
  end

  class_methods do
    def permitted_params
      filters.map do |filter_name, filter|
        next unless filter.options[:permit]

        case filter
        when ActiveInteraction::ArrayFilter
          { filter_name => [] }
        when ActiveInteraction::HashFilter
          { filter_name => {} }
        else
          filter_name
        end
      end.compact
    end
  end
end
