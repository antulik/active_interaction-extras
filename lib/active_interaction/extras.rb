require "active_interaction/extras/version"

require 'active_support'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/concerning'

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

    autoload(:Current, "active_interaction/extras/current")
    autoload(:FilterAlias, "active_interaction/extras/filter_alias")
    autoload(:Halt, "active_interaction/extras/halt")
    autoload(:ModelFields, "active_interaction/extras/model_fields")
    autoload(:NamedCallbacks, "active_interaction/extras/named_callbacks")
    autoload(:NestedAttributes, "active_interaction/extras/nested_attributes")
    autoload(:RunCallback, "active_interaction/extras/run_callback")
    autoload(:StrongParams, "active_interaction/extras/strong_params")
    autoload(:Transaction, "active_interaction/extras/transaction")

    autoload(:TimezoneSupport, "active_interaction/extras/timezone_support")
    autoload(:Rspec, "active_interaction/extras/rspec")

    autoload(:ActiveJob, "active_interaction/extras/active_job")
    autoload(:GoodJob, "active_interaction/extras/good_job")
    autoload(:Sidekiq, "active_interaction/extras/sidekiq")

    concern :FormFor do
      class_methods do
        def form_for(field_name)
          delegate :persisted?, :id, :to_param, to: field_name
        end
      end
    end

    concern :AfterInitialize do
      include ActiveSupport::Callbacks

      included do
        define_callbacks :initialize
      end

      class_methods do
        def after_initialize(...)
          set_callback(:initialize, :after, ...)
        end
      end

      def initialize(...)
        super
        run_callbacks :initialize, :after
      end
    end

    concern :InitializeWith do
      include ActiveInteraction::Extras::AfterInitialize

      class_methods do
        def initialize_with(&block)
          after_initialize do
            hash = instance_exec(&block)
            hash&.each do |filter_name, value|
              public_send "#{filter_name}=", value if !inputs.given?(filter_name)
            end
          end
        end
      end
    end

    concern :IncludeErrors do
      include ActiveInteraction::Extras::Halt

      def include_errors!(model, **mapping)
        errors.merge! model.errors, **mapping
        halt_if_errors!
      end
    end
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
