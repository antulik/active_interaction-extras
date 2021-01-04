module ActiveInteraction::Extras::Rspec
  # Helper method to stub service objects in unit tests, while verifying
  # that they are called with valid arguments.
  #
  # This stub does NOT run after_run callbacks.
  #
  # @param [Class] klass Service class to stub
  #
  # @param [Hash] opts
  # @option opts [Boolean] :fail (false) If execution should add error
  # @option opts (see Rspec::Mocks::MessageExpectation#with) :with (any_args)
  #   Inputs for the service
  # @option opts (void) :return (nil) Execution return value
  # @option opts (void) :execute (Proc) Execution proc
  #
  # @example Simple stub
  #   expect_to_execute(X)
  #
  # @example With all arguments
  #   expect_to_execute(X, with: hash_including(:key), return: 1, fail: false)
  #
  # @return [void]
  #
  def expect_to_execute(klass, opts = {})
    stub_service_execute(:expect, klass, opts)
  end

  # @see #expect_to_execute
  def allow_to_execute(klass, opts = {})
    stub_service_execute(:allow, klass, opts)
  end

  # Stub service run method. Does not validate inputs
  #
  # @see #expect_to_execute
  def expect_to_run(klass, opts = {})
    stub_service_run(:expect, klass, opts)
  end

  # @see #expect_to_run
  def allow_to_run(klass, opts = {})
    stub_service_run(:allow, klass, opts)
  end

  # Make sure the service is not initialized
  #
  # @param [Class] klass Service class to stub
  #
  # @param [Hash] opts
  # @option opts (see Rspec::Mocks::MessageExpectation#with) :with (any_args)
  #   Inputs for the service
  #
  def expect_not_to_run(klass, opts = {})
    alias_new_method(klass)
    with = service_parse_with_option(opts)

    expect(klass).to_not receive(:new).with(*with)
  end

  alias expect_to_not_run expect_not_to_run

  def expect_to_not_run_delayed(klass, opts = {})
    alias_delay_method(klass)

    with = service_parse_job_with_option(opts)

    expect(klass).to_not receive(:delay).with(*with)
  end

  alias expect_not_to_run_delayed expect_to_not_run_delayed

  # see expect_to_run
  #
  # additional params
  #
  # @option opts (see Rspec::Mocks::MessageExpectation#with) :with_job (any_args)
  #   queueing params for the job
  #
  def expect_to_delay_run(klass, opts = {})
    stub_service_delay :expect, :expect_to_run, klass, opts
  end

  # see expect_to_execute
  # same but for the .delay and background queueing
  #
  # additional params
  #
  # @option opts (see Rspec::Mocks::MessageExpectation#with) :with_job (any_args)
  #   queueing params for the job
  #
  def expect_to_delay_execute(klass, opts = {})
    stub_service_delay :expect, :expect_to_execute, klass, opts
  end

  # see allow_to_run
  #
  # additional params
  #
  # @option opts (see Rspec::Mocks::MessageExpectation#with) :with_job (any_args)
  #   queueing params for the job
  #
  def allow_to_delay_run(klass, opts = {})
    stub_service_delay :allow, :allow_to_run, klass, opts
  end

  # see allow_to_execute
  #
  # additional params
  #
  # @option opts (see Rspec::Mocks::MessageExpectation#with) :with_job (any_args)
  #   queueing params for the job
  #
  def allow_to_delay_execute(klass, opts = {})
    stub_service_delay :allow, :allow_to_execute, klass, opts
  end

  # @private
  def stub_service_delay(expectation, expect_helper, klass, opts)
    alias_delay_method(klass)

    with = service_parse_job_with_option(opts)

    send(expectation, klass).to(
      # ^^^^^
      # If failed here, the .delay method was not called
      # or called with invalid arguments
      #
      receive(:delay).with(*with) do |*args|
        # get the original .delay return value
        delayed_run = klass.original_delay(*args)

        opts[:execute] ||= proc do |instance|
          # call original queueing logic, so the argument serialisation is triggered
          delayed_run.run(instance.raw_inputs)
        end

        send(expect_helper, klass, opts)
        klass
      end,
    )
  end

  # @private
  def stub_service_run(expectation, klass, opts)
    stub_service_validate_opts opts
    alias_new_method(klass)
    with = service_parse_with_option(opts)

    send(expectation, klass).to(
      # ^^^^^^^^^^^^^^^^^^^^^^^^
      # If failed here, the service did not run
      #
      receive(:new).with(*with) do |*args|
        instance = klass.original_new(*args)
        send(expectation, instance).to receive(:run) do
          instance.errors.add :base, 'forced test failure' if opts[:fail]

          instance.result =
            if opts[:execute].respond_to? :call
              opts[:execute].call(instance)
            else
              opts[:return]
            end

          instance
        end
        instance
      end,
    )
  end

  # @private
  def stub_service_execute(expectation, klass, opts)
    stub_service_validate_opts opts
    alias_new_method(klass)
    with = service_parse_with_option(opts)

    # TODO: change so rspec displays correct message
    send(expectation, klass).to(
      # ^^^^^^^^^^^^^^^^^^^^^^^
      # If failed here, the service was not called
      #
      receive(:new).with(*with) do |*args|
        instance = klass.original_new(*args)
        instance.disable_after_run_callback
        send(expectation, instance).to(
          #
          # If failed here, the service was called, but failed because it's invalid
          #
          receive(:execute) do
            instance.errors.add :base, 'forced test failure' if opts[:fail]

            if opts[:execute].respond_to? :call
              opts[:execute].call(instance)
            else
              opts[:return]
            end
          end,
        )

        instance
      end,
    )
  end

  # @private
  def alias_new_method(klass)
    return if klass.respond_to?(:original_new)

    klass.define_singleton_method :original_new, &klass.method(:new)
  end

  # @private
  def alias_delay_method(klass)
    return if klass.respond_to?(:original_delay)

    klass.define_singleton_method :original_delay, &klass.method(:delay)
  end

  # @private
  def service_parse_with_option(opts)
    with = opts.fetch(:with, [any_args])
    with = [with] unless with.is_a? Array
    with
  end

  def service_parse_job_with_option(opts)
    with_opts = {}
    with_opts[:with] = opts.delete(:job_with) if opts.key? :job_with
    service_parse_with_option(with_opts)
  end

  # @private
  def stub_service_validate_opts(opts)
    raise ArgumentError, 'Pick one :return or :execute, but not both' if opts.key?(:return) && opts.key?(:execute)

    invalid_keys = opts.except(:fail, :return, :with, :execute).keys
    raise ArgumentError, 'Unknown options: ' + invalid_keys.to_s if invalid_keys.any?
  end
end
