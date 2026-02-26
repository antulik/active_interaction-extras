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

          if filters.key?(field_name)
            klass = filters.fetch(field_name).send(:klass)
            model_name.route_key = klass.model_name.route_key
            model_name.singular_route_key = klass.model_name.singular_route_key
          end

          Rails.application.routes.add_polymorphic_mapping(name, {}) do |form|
            form.send(field_name)
          end
        end
      end
    end

    concern :ModelNames do
      class_methods do
        def inherited(subclass)
          super.tap { subclass.set_model_naming }
        end

        def set_model_naming
          str = name.deconstantize.underscore
          model_name.route_key = str.pluralize.to_sym
          model_name.singular_route_key = str.singularize.to_sym
        end

        def singular_resource_route_key!
          str = name.deconstantize.underscore
          model_name.route_key = str.singularize.to_sym
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

    concern :AllRunner do
      class AllExecution
        attr_reader :klass, :params

        def initialize(klass:, params:)
          @klass = klass
          @params = params
        end

        def run(opts = {})
          execute(opts) { klass.run(_1) }
        end

        def run!(opts = {})
          execute(opts) { klass.run!(_1) } 
        end

        def delay(**delay_opts)
          DelayedExecution.new(klass:, params:, delay_opts:)
        end

        private

        def noop
          yield
        end

        def default_params
          object_filters = klass.filters
            .reject { _2.default? }
            .select { _2.is_a?(ActiveInteraction::ObjectFilter) }
          raise "only one object input allowed" if object_filters.size > 1
          name, _ = object_filters.first

          {
            name => name.to_s.classify.constantize.all,
          }
        end

        def execute(opts, around: method(:noop))
          params = self.params.dup.reverse_merge(default_params)

          name, scope = params.find { _2.is_a?(ActiveRecord::Relation) }
          params.delete(name)

          scope.find_in_batches do |batch|
            around.call do
              batch.each do |record|
                yield(opts.merge(name => record, **params))
              end
            end
          end
        end
      end

      class DelayedExecution < AllExecution
        attr_reader :delay_opts
        def initialize(delay_opts: {}, **kw)
          super(**kw)
          @delay_opts = delay_opts
        end

        def run(opts = {})
          require 'good_job'
          around = ::GoodJob::Bulk.method(:enqueue)
          execute(opts, around:) { klass.delay(delay_opts).run(_1) }
        end

        def run!(opts = {})
          run(opts)
        end
      end

      class_methods do
        def all(params = {})
          AllExecution.new(klass: self, params:)
        end
      end
    end


    concern :AppendInputs do
      module InputsRefinement
        refine ActiveInteraction::Inputs do
          # Based on ActiveInteraction::Inputs#initialize
          def append(raw_inputs, overwrite: false)
            new_normalized_inputs = normalize(raw_inputs)

            keys = new_normalized_inputs.keys.map(&:to_sym)
            keys = keys.reject { given?(_1) } if !overwrite

            new_inputs = @base.class.filters
              .slice(*keys)
              .each_with_object({}) do |(name, filter), inputs|
              inputs[name] = filter.process(new_normalized_inputs[name], @base)

              yield(name, inputs[name]) if block_given?
            end

            @normalized_inputs = @normalized_inputs.merge(new_normalized_inputs)
            @inputs = @inputs.merge(new_inputs)
            @to_h = nil
          end
        end
      end

      using InputsRefinement

      def default_inputs(*args)
        inputs.append(*args) do |name, input|
          public_send("#{name}=", input.value)
        end
      end

      # def default_input(name, &block)
      #   if !inputs.given?(name)
      #     default_inputs(name: block.call)
      #   end
      # end

      class_methods do
        def default_inputs(&block)
          after_initialize do
            hash = block.call
            default_inputs(hash)
          end
        end

        def default_input(name, &block)
          after_initialize do
            default_inputs(name => instance_exec(&block))
          end
        end
      end
    end

    concern :FileBlobs do
      def blobs_for(array_field)
        # If there is a new upload field, prioritize it
        new_upload = "new_#{array_field}"
        if respond_to?(new_upload) && public_send(new_upload).present?
          array_field = new_upload
        end

        list = public_send(array_field)
        list = Array.wrap(list)

        list.compact_blank.map do |file|
          case file
          when ActiveStorage::Blob
            file
          when ActiveStorage::Attachment, ActiveStorage::Attached::One
            file.blob
          when String
            ActiveStorage::Blob.find_signed(file)
          end
        end.compact
      end
    end
  end
end

require 'active_interaction/extras/filters/anything_filter'
require 'active_interaction/extras/filters/ar_relation_filter'
require 'active_interaction/extras/filters/uuid_filter'

I18n.load_path.unshift(
  *Dir.glob(
    File.expand_path(
      File.join(%w[extras locale *.yml]), File.dirname(__FILE__)
    )
  )
)
