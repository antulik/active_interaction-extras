module ActiveInteraction::Extras::Transaction
  extend ActiveSupport::Concern

  def run_in_transaction!
    result_or_errors = nil
    ActiveRecord::Base.transaction do
      result_or_errors = yield

      # check by class because
      # errors added by compose method are merged after execute,
      # so we need to check return type ourselves
      #
      # see ActiveInteraction::Runnable#run
      if result_or_errors.is_a?(ActiveInteraction::Errors) && result_or_errors.any?
        raise ActiveRecord::Rollback
      end

      raise ActiveRecord::Rollback if errors.any?
    end
    result_or_errors
  end

  class_methods do
    def run_in_transaction!
      set_callback :execute, :around, :run_in_transaction!, prepend: true
    end

    def skip_run_in_transaction!
      skip_callback :execute, :around, :run_in_transaction!
    end
  end
end
