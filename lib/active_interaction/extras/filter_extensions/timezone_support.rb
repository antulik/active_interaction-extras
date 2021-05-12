# frozen_string_literal: true

# Implementation inspired by
# https://github.com/AaronLasseigne/active_interaction/blob/c9d5608c3b8aab23d463f99c832b2ac5139911de/lib/active_interaction/filters/abstract_date_time_filter.rb#L42
module ActiveInteraction::Extras::FilterExtensions::TimezoneSupport
  def convert_string(value)
    if time_with_zone?
      Time.zone.parse(value) ||
        raise(ArgumentError, "no time information in #{value.inspect}")
    else
      super
    end
  end
end

ActiveInteraction::TimeFilter.include(ActiveInteraction::Extras::FilterExtensions::TimezoneSupport)
