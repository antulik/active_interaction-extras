require "active_support/core_ext/object/with_options"

module ActiveInteraction::Extras::ModelFields
  extend ActiveSupport::Concern
  include ActiveInteraction::Extras::AfterInitialize

  class Context < SimpleDelegator
    attr_accessor :from_model_name
    attr_accessor :model_field_cache

    def custom_filter_attribute(name, opts = {}, &block)
      from_model_name = self.from_model_name
      model_field_cache[from_model_name] = model_field_cache[from_model_name] << name

      __getobj__.send __callee__, name, opts, &block
    end

    alias interface custom_filter_attribute
    alias date custom_filter_attribute
    alias time custom_filter_attribute
    alias date_time custom_filter_attribute
    alias integer custom_filter_attribute
    alias decimal custom_filter_attribute
    alias float custom_filter_attribute
    alias string custom_filter_attribute
    alias symbol custom_filter_attribute
    alias object custom_filter_attribute
    alias hash custom_filter_attribute
    alias file custom_filter_attribute
    alias boolean custom_filter_attribute
    alias array custom_filter_attribute
    alias record custom_filter_attribute

    alias anything custom_filter_attribute
    alias uuid custom_filter_attribute
  end

  included do
    after_initialize :assign_model_values_to_filters
  end

  # returns hash of all model fields and their values
  def model_fields(model_name)
    fields = self.class.model_field_cache[model_name]
    fields.to_h do |field|
      [field, public_send(field)]
    end
  end

  # returns hash of only changed model fields and their values
  def changed_model_fields(model_name)
    model_fields(model_name).select do |field, _value|
      any_changed?(field)
    end
  end

  def save_model!(model_name)
    model = public_send(model_name)
    model.assign_attributes(model_fields(model_name))
    model.save
    include_errors! model
    model
  end

  def save_model_changes!(model_name)
    model = public_send(model_name)
    model.assign_attributes(changed_model_fields(model_name))
    model.save
    include_errors! model
    model
  end

  # returns hash of only given model fields and their values
  def given_model_fields(model_name)
    model_fields(model_name).select do |field, _value|
      inputs.given?(field)
    end
  end

  # checks if value was given to the service and the value is different from
  # the one on the model
  def any_changed?(*fields)
    fields.any? do |field|
      if inputs.given?(field)
        model_field = self.class.model_field_cache_inverse[field]

        if model_field
          send(model_field).send(field) != send(field)
        else
          true
        end
      end
    end
  end

  def assign_model_values_to_filters
    self.class.filters.each do |name, filter|
      next if inputs.given?(name)

      model_field = self.class.model_field_cache_inverse[name]
      next if model_field.nil?

      value = public_send(model_field)&.public_send(name)
      input = filter.process(value, self)
      public_send("#{name}=", input.value)
    end
  end

  class_methods do
    def model_field_cache
      @model_field_cache ||= Hash.new { [] }
    end

    def model_field_cache_inverse
      @model_field_cache_inverse ||= model_field_cache.each_with_object({}) do |(model, fields), result|
        fields.each do |field|
          result[field] = model
        end
      end
    end

    # Default values from the model in the other field
    #
    #  object :user
    #  model_fields(:user) do
    #    string :first_name
    #    string :last_name
    #  end
    #
    # >> interaction.new(user: User.new(first_name: 'John')).first_name
    # => 'John'
    #
    def model_fields(model_name, opts = {}, &block)
      if block
        ref_model_field_cache = model_field_cache
        opts.reverse_merge!(default: nil, permit: true)

        with_options opts do
          context = Context.new(self)
          context.from_model_name = model_name
          context.model_field_cache = ref_model_field_cache

          context.instance_exec(&block)
        end
      end

      model_field_cache[model_name]
    end
  end
end
