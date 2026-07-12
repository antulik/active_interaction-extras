module ActiveInteraction::Extras::ModelNames
  extend ActiveSupport::Concern

  class_methods do
    def inherited(subclass)
      super.tap { subclass.set_model_naming }
    end

    def set_model_naming
      str = name.deconstantize.underscore
      model_name.route_key = str.pluralize.to_sym
      model_name.singular_route_key = str.singularize.to_sym
    end

    def singular_resource_route_key!
      str = name.deconstantize.underscore
      model_name.route_key = str.singularize.to_sym
    end
  end
end
