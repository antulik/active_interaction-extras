# frozen_string_literal: true

class ActiveInteraction::Extras::Filters::AnythingFilter < ActiveInteraction::Filter
  register :anything

  def matches?(_object)
    true
  end
end
