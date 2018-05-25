require 'active_interaction/active_job'

class TestableService < ActiveInteraction::Base
  include ActiveInteraction::Extras::All

  class Job < ActiveJob::Base
    include ActiveInteraction::Extras::ActiveJob::Perform
  end
end
