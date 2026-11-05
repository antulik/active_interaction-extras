# inspired by store_model/nested_attributes.rb
module ActiveInteraction::Extras::NestedAttributes
  extend ActiveSupport::Concern

  module InputsExtension
    extend ActiveSupport::Concern

    def normalize(inputs)
      if @base.class.respond_to? :nested_attribute_options
        @base.class.nested_attribute_options.each do |attribute, options|
          alias_name = "#{attribute}_attributes"
          next if !inputs.key?(alias_name) && !inputs.key?(alias_name.to_sym)

          value = inputs[alias_name] || inputs[alias_name.to_sym]
          value = @base.class.process_nested_collection(attribute, value, options)

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

  def save_collection(list, new_list,
    updated: -> { _2.save },
    removed: -> { it.destroy },
    added: -> { it.save }
  )
    old_list = list.to_a.dup

    new_list.each do |new_record|
      index = old_list.index { it.id == new_record.id }
      if index
        existing_record = old_list.delete_at(index)
        if updated
          updated.call(existing_record, new_record)
        else
          yield(existing_record, new_record, :updated)
        end
      else
        if added
          added.call(new_record)
        else
          yield(nil, new_record, :added)
        end
      end
    end

    old_list.each do |record|
      if removed
        removed.call(record)
      else
        yield(record, nil, :removed)
      end
    end
  end

  class_methods do
    # @example
    #   class User::Form < BaseService
    #     object :user
    #
    #     model_fields(:user) do
    #       array :user_times, default: [] do
    #         object class: UserTime
    #       end
    #     end
    #
    #     accepts_nested_attributes_for :user_times,
    #       permit: %i[day start_seconds end_seconds],
    #       allow_destroy: true
    #
    #     def execute
    #       user_times.each { it.user = user }
    #       save_collection(user.user_times, user_times)
    #       include_collection_errors! :user_times
    #
    #       save_model! :user
    #     end
    #   end
    def accepts_nested_attributes_for(*attributes)
      options = attributes.extract_options!
      options.assert_valid_keys(:allow_destroy, :reject_if, :permit)
      options.reverse_merge!(allow_destroy: false)

      if options.key?(:permit)
        if options[:permit].is_a?(Array)
          options[:permit] |= [:id, :_destroy]
        end
      else
        raise ArgumentError, "missing :permit option"
      end

      attributes.each do |attribute|
        # disable permit for original attribute
        filters[attribute].options[:permit] = false

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
        attributes = self.class.process_nested_collection(association, attributes, options)
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

    def process_nested_collection(association, attributes, options = nil)
      attributes = attributes.values if attributes.is_a?(Hash)
      if options&.dig(:allow_destroy)
        attributes.reject! do |attribute|
          ActiveRecord::Type::Boolean.new.cast(attribute.stringify_keys.dig("_destroy"))
        end
      end

      attributes.reject! { |attribute| call_reject_if(attribute, options[:reject_if]) } if options&.dig(:reject_if)

      sub_filter = filters[association].filters[:"0"]
      if sub_filter
        if sub_filter.options[:converter]
          attributes = attributes.map do |attrs|
            sub_filter.send(:converter, attrs)
          end

        elsif sub_filter.is_a?(ActiveInteraction::ObjectFilter)
          cast_class = sub_filter.send(:klass)

          ids = attributes.map { it["id"] }.compact_blank
          by_ids = ids.present? ? Array.wrap(cast_class.find(*ids)).index_by { it.id } : {}

          attributes = attributes.map do |attrs|
            attrs = attrs.except("_destroy")

            if attrs["id"].present?
              record = by_ids.fetch attrs["id"]
              record.assign_attributes(attrs)
              record
            else
              cast_class.new(attrs)
            end
          end
        end
      end

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
end
