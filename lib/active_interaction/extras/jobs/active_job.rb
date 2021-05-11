require 'active_interaction/active_job'

module ActiveInteraction::Extras::Jobs::ActiveJob
  extend ActiveSupport::Concern

  include ActiveInteraction::ActiveJob::Core

  module Perform
    extend ActiveSupport::Concern

    include  ActiveInteraction::ActiveJob::JobHelper
  end
end
