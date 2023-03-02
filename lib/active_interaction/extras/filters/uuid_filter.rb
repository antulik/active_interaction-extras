# frozen_string_literal: true

class ActiveInteraction::Extras::Filters::UUIDFilter < ActiveInteraction::StringFilter
  register :uuid

  REGEX = /^[0-9A-F]{8}-[0-9A-F]{4}-[4][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i.freeze

  def matches?(value)
    super && REGEX.match?(value)
  end

  def convert(value)
    value, error = super
    if error
      [value, error]
    else
      [value&.presence, nil]
    end
  end
end
