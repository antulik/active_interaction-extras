module ActiveInteraction::Extras::AllRunner
  extend ActiveSupport::Concern

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
    # class Service < ActiveInteraction::Base
    #   object :user
    #   def execute; end
    # end
    #
    # @example
    #   Service.all.run!
    #   Service.all.run
    #   Service.all.delay.run!
    #   Service.all(user: User.all).delay(wait: 5.minutes).run!
    def all(params = {})
      AllExecution.new(klass: self, params:)
    end
  end
end
