module ActiveInteraction::Extras::StrongParams
  extend ActiveSupport::Concern

  def initialize(inputs = {})
    # TODO: whitelist :params and :form_params, so they could not be used as filters
    return super if self.class.filters.key?(:params) || self.class.filters.key?(:form_params)

    return super if %i[fetch key? merge].any? { |m| !inputs.respond_to?(m) }

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
      permissions = filters.map do |filter_name, filter|
        [
          permission_for_filter(filter, filter_name),
          # (permission_for_filter(filter, filter.options[:as]) if filter.options[:as])
        ]
      end.flatten(1).compact

      if respond_to?(:nested_attribute_options)
        nested_attribute_options.each do |attribute, _|
          permissions << {"#{attribute}_attributes": {}}
        end
      end

      permissions
    end

    def permission_for_filter(filter, name = filter.name)
      permit = filter.options[:permit]
      return unless permit

      case filter
      when ActiveInteraction::ArrayFilter
        value =
          if permit == true
            nested_type = filter.filters.values.first
            case nested_type
            when ActiveInteraction::HashFilter, ActiveInteraction::ObjectFilter
              {}
            else
              []
            end
          else
            permit
          end

        { name => value }
      when ActiveInteraction::HashFilter, ActiveInteraction::ObjectFilter
        { name => {} }
      else
        name
      end
    end
  end
end
