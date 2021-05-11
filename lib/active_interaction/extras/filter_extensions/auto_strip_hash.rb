# frozen_string_literal: true

# If hash specified without structure automatically accept full hash
#
# @example Accept all keys
#   hash :options
#
# @example Accept only specified keys
#   hash :options do
#     string :name
#   end
#
# @example Accept all keys
#   hash :options, strip: false do
#     string :name
#   end
#
module ActiveInteraction::Extras::FilterExtensions::AutoStripHash
  def initialize(*)
    super
    options[:strip] = false if !block_given? && !options.key?(:strip)
  end
end

ActiveInteraction::HashFilter.prepend(ActiveInteraction::Extras::FilterExtensions::AutoStripHash)
