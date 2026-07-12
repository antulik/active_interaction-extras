module ActiveInteraction::Extras::FormFor
  extend ActiveSupport::Concern

  class_methods do
    # Changes route key so url helpers work
    #
    # @example
    #   class User::Form < ActiveInteraction::Base
    #     object :user
    #     form_for :user
    #   end
    #
    #   url_for(form) #=> "/users/1"
    def form_for(field_name)
      delegate :persisted?, :id, :to_param, to: field_name

      if filters.key?(field_name)
        klass = filters.fetch(field_name).send(:klass)
        model_name.route_key = klass.model_name.route_key
        model_name.singular_route_key = klass.model_name.singular_route_key
      end

      # TODO: Routes reload is broken in Dev
      # Resolve form object route to object
      # e.g. resolve "User::Form" { |form| form.user }
      # Rails.application.config.after_routes_loaded do |app|
      #   app.routes.add_polymorphic_mapping(name, {}) do |form|
      #     form.send(field_name)
      #   end
      # end
    end
  end
end
