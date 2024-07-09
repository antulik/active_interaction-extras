# frozen_string_literal: true

# Add :as option, which is a read alias to filter
#   hash :account, as: :account_attributes
#
module ActiveInteraction::Extras::FilterAlias
  extend ActiveSupport::Concern

  # concern :InputsExtension do
  #   def normalize(inputs)
  #     @base.class.filters.each do |name, filter|
  #       alias_name = filter.options[:as]
  #
  #       if alias_name.nil?
  #         next
  #
  #       elsif inputs.key?(alias_name.to_sym)
  #         inputs[name.to_sym] = inputs[alias_name.to_sym]
  #
  #       elsif inputs.key?(alias_name.to_s)
  #         inputs[name.to_s] = inputs[alias_name.to_s]
  #       end
  #     end
  #
  #     super
  #   end
  # end
  #
  # included do
  #   ActiveInteraction::Inputs.prepend InputsExtension
  # end

  class_methods do
    def initialize_filter(filter)
      super.tap do
        if filter.options[:as]
          name = filter.options[:as]
          alias_method name, filter.name
          # alias_method "#{name}=", "#{filter.name}="
        end
      end
    end
  end
end
