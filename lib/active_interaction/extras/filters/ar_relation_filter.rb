# frozen_string_literal: true

class ActiveInteraction::Extras::Filters::ArRelationFilter < ActiveInteraction::ObjectFilter
  register :ar_relation

  def initialize(...)
    super
    @options.reverse_merge!(class: ActiveRecord::Relation)
  end

  def matches?(value)
    # value == nil triggers active record loading
    if value.nil? && default?
      # as per v5 there is no way to know if value of `nil` is given by caller or
      # is a default value when it's missing. We want to maintain standard default
      # behaviour when value is `nil`. Returning `false` will trigger default value
      false
    else
      true
    end
  end
end
