# frozen_string_literal: true

class ActiveInteraction::Extras::Filters::AnythingFilter < ActiveInteraction::Filter
  register :anything

  def matches?(value)
    if value == nil && default?
      # as per v5 there is no way to know if value of `nil` is given by caller or
      # is a default value when it's missing. We want to maintain standard default
      # behaviour when value is `nil`. Returning `false` will trigger default value
      false
    else
      true
    end
  end
end
