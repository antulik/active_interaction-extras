require "active_interaction/extras/version"

require 'active_support'
require 'active_interaction'

module ActiveInteraction
  module Extras
    module Filters
    end

    module FilterExtensions
    end

    module Jobs
      autoload(:Core, "active_interaction/extras/jobs/core")
    end

    autoload(:All, "active_interaction/extras/all")

    autoload(:FilterAlias, "active_interaction/extras/filter_alias")
    autoload(:Halt, "active_interaction/extras/halt")
    autoload(:ModelFields, "active_interaction/extras/model_fields")
    autoload(:RunCallback, "active_interaction/extras/run_callback")
    autoload(:StrongParams, "active_interaction/extras/strong_params")
    autoload(:Transaction, "active_interaction/extras/transaction")

    autoload(:TimezoneSupport, "active_interaction/extras/timezone_support")
    autoload(:Rspec, "active_interaction/extras/rspec")

    autoload(:ActiveJob, "active_interaction/extras/active_job")
    autoload(:Sidekiq, "active_interaction/extras/sidekiq")
  end
end

require 'active_interaction/extras/filters/anything_filter'
require 'active_interaction/extras/filters/uuid_filter'

I18n.load_path.unshift(
  *Dir.glob(
    File.expand_path(
      File.join(%w[extras locale *.yml]), File.dirname(__FILE__)
    )
  )
)
