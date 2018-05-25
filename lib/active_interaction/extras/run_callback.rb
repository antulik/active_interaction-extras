module ActiveInteraction::Extras::RunCallback
  extend ActiveSupport::Concern

  included do
    define_callbacks :run
  end

  def run
    run_callbacks(:run) do
      super
    end
  end

  def after_run_callback_enabled?
    !@after_run_callback_disabled
  end

  def enable_after_run_callback
    @after_run_callback_disabled = false
  end

  # This is useful for testing
  def disable_after_run_callback
    @after_run_callback_disabled = true
  end

  class_methods do
    # Run callback is executed outside transaction if transaction is used.
    # Make sure code in after_run hook can't fail, so preferably only run async code here
    def after_run(*args, &block)
      opts = args.extract_options!
      opts[:if] = [:after_run_callback_enabled?] + Array(opts[:if])

      set_callback :run, :after, *args, opts, &block
    end

    # See #after_run
    # only runs when service has successfully finished and outcome is valid
    def after_successful_run(*args, &block)
      opts = args.extract_options!
      opts[:if] = [:valid?, :after_run_callback_enabled?] + Array(opts[:if])

      set_callback :run, :after, *args, opts, &block
    end

    # See #after_run
    def after_failed_run(*args, &block)
      opts = args.extract_options!
      opts[:if] = [:after_run_callback_enabled?] + Array(opts[:if])
      opts[:unless] = [:valid?] + Array(opts[:unless])

      set_callback :run, :after, *args, opts, &block
    end
  end
end
