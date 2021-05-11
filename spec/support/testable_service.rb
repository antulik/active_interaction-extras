require 'active_interaction/active_job'
require 'active_interaction/extras/filter_extensions'

class TestableService < ActiveInteraction::Base
  include ActiveInteraction::Extras::All
end
