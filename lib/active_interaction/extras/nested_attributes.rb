# inspired by store_model/nested_attributes.rb
module ActiveInteraction::Extras::NestedAttributes
  extend ActiveSupport::Concern

  concern :InputsExtension do
    def normalize(inputs)
      if @base.class.respond_to? :nested_attribute_options
        @base.class.nested_attribute_options.each do |attribute, options|
          alias_name = "#{attribute}_attributes"
          next if !inputs.key?(alias_name) && !inputs.key?(alias_name.to_sym)

          value = inputs[alias_name] || inputs[alias_name.to_sym]
          value = @base.class.process_nested_collection(value, options)

          inputs[attribute.to_s] = value
        end
      end

      super
    end
  end

  included do
    ActiveInteraction::Inputs.prepend InputsExtension

    class_attribute :nested_attribute_options, default: {}
  end

  class_methods do
    def accepts_nested_attributes_for(*attributes)
      options = attributes.extract_options!
      options.reverse_merge!(allow_destroy: false, update_only: false)

      if options.key?(:permit)
        if options[:permit].is_a?(Array)
          options[:permit] |= [:id, :_destroy]
        end
      else
        raise ArgumentError, "missing :permit option"
      end

      attributes.each do |attribute|
        nested_attribute_options[attribute] = options

        case filters[attribute]
        when ActiveInteraction::ArrayFilter
          define_association_setter_for_many attribute, options
        else
          define_association_setter_for_single(attribute, options)
          define_method "#{attribute}_attributes=" do |*args, **kwargs|
            send("#{attribute}=", *args, **kwargs)
          end
        end
      end
    end

    def define_association_setter_for_many(association, options)
      define_method "#{association}_attributes=" do |attributes|
        attributes = self.class.process_nested_collection(attributes, options)
        send("#{association}=", attributes)
      end
    end

    def define_association_setter_for_single(association, options)
      return unless options&.dig(:allow_destroy)

      define_method "#{association}=" do |attributes|
        if ActiveRecord::Type::Boolean.new.cast(attributes.stringify_keys.dig("_destroy"))
          super(nil)
        else
          super(attributes)
        end
      end
    end

    def process_nested_collection(attributes, options = nil)
      attributes = attributes.values if attributes.is_a?(Hash)
      if options&.dig(:allow_destroy)
        attributes.reject! do |attribute|
          ActiveRecord::Type::Boolean.new.cast(attribute.stringify_keys.dig("_destroy"))
        end
      end

      attributes.reject! { |attribute| call_reject_if(attribute, options[:reject_if]) } if options&.dig(:reject_if)

      attributes
    end

    def call_reject_if(attributes, callback)
      callback = ActiveRecord::NestedAttributes::ClassMethods::REJECT_ALL_BLANK_PROC if callback == :all_blank

      case callback
      when Symbol
        method(callback).arity.zero? ? send(callback) : send(callback, attributes)
      when Proc
        callback.call(attributes)
      end
    end
  end

  def assign_collection_association(model, association_name, attributes_collection, destroy_missing: false, **options)

    if attributes_collection.is_a?(ActiveRecord::Associations::CollectionProxy)
      return attributes_collection
    end

    model.instance_exec do
      begin
        old_options = nested_attributes_options[association_name]
        nested_attributes_options[association_name] = options

        list = assign_nested_attributes_for_collection_association(association_name, attributes_collection)

        if destroy_missing
          association(association_name).scope.excluding(list).each(&:destroy!)
        end

        list
      ensure
        nested_attributes_options[association_name] = old_options
      end
    end
  end
end
