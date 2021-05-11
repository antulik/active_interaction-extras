# frozen_string_literal: true

# Add support for polymorphic objects
#   object :account, class: [Account, AnyoneAccount]
#
module ActiveInteraction::Extras::FilterExtensions::MultiObject
  def class_list
    class_names.map do |klass_name|
      case klass_name
      when Class
        klass_name
      else
        begin
          Object.const_get(klass_name.to_s.camelize)
        rescue NameError
          raise ActiveInteraction::InvalidNameError, "class #{klass_name.inspect} does not exist"
        end
      end
    end
  end

  def klass
    if polymorphic?
      class_list.first
    else
      super
    end
  end

  def matches?(value)
    if polymorphic?
      class_list.any? { |klass| value.class <= klass }
    else
      super
    end
  end

  def class_names
    options.fetch(:class, name)
  end

  def polymorphic?
    class_names.is_a? Array
  end
end

ActiveInteraction::ObjectFilter.prepend(ActiveInteraction::Extras::FilterExtensions::MultiObject)
