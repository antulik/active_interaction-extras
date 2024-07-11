# Add transaction wrapper
#   run_in_transaction!
#   skip_run_in_transaction!
module ActiveInteraction::Extras::Transaction
  extend ActiveSupport::Concern

  included do
    class_attribute :run_in_transaction_options

    around_execute if: :run_in_transaction_options do |_interaction, block|
      ActiveRecord::Base.transaction(**run_in_transaction_options) do
        block.call
        raise ActiveRecord::Rollback if _interaction.errors.any?
      end
    end
  end

  class_methods do
    # https://pragtob.wordpress.com/2017/12/12/surprises-with-nested-transactions-rollbacks-and-activerecord/
    def run_in_transaction!(enabled = true, requires_new: true)
      value =
        if enabled
          { requires_new: requires_new }
        else
          false
        end

      self.run_in_transaction_options = value
    end

    def skip_run_in_transaction!
      self.run_in_transaction_options = false
    end

    def force_explicit_transactions!
      before_filter do
        if run_in_transaction_options.nil?
          raise "Missing transaction definition. Add `run_in_transaction!`."
        end
      end
    end

    def list_missing_transaction_definition
      Zeitwerk::Loader.eager_load_all
      descendants
        .select { |klass| klass.run_in_transaction_options.nil? }
    end
  end
end
