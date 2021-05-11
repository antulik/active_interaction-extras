# frozen_string_literal: true

# Add :as option, which is a read alias to filter
#   hash :params, as: :account_attributes
#
module ActiveInteraction::Extras::FilterAlias
  extend ActiveSupport::Concern

  class_methods do
    def initialize_filter(filter)
      super.tap do
        if filter.options[:as]
          alias_method filter.options[:as], filter.name
        end
      end
    end
  end
end
