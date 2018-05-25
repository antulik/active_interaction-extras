require 'active_interaction/active_job'

module ActiveInteraction::Extras::Sidekiq
  extend ActiveSupport::Concern

  include ActiveInteraction::ActiveJob::Sidekiq::Core

  module Perform
    extend ActiveSupport::Concern

    include  ActiveInteraction::ActiveJob::Sidekiq::JobHelper
  end
end
