require "active_interaction/extras/version"

require 'active_support'
require 'active_interaction'

module ActiveInteraction
  module Extras

    autoload(:All, "active_interaction/extras/all")

    autoload(:Halt, "active_interaction/extras/halt")
    autoload(:ModelFields, "active_interaction/extras/model_fields")
    autoload(:RunCallback, "active_interaction/extras/run_callback")
    autoload(:StrongParams, "active_interaction/extras/strong_params")
    autoload(:Transaction, "active_interaction/extras/transaction")

    autoload(:ActiveJob, "active_interaction/extras/active_job")
    autoload(:Sidekiq, "active_interaction/extras/sidekiq")

    autoload(:Rspec, "active_interaction/extras/rspec")
  end
end
