# Add transaction wrapper
#   run_in_transaction!
#   skip_run_in_transaction!
module ActiveInteraction::Extras::Transaction
  extend ActiveSupport::Concern

  included do
    class_attribute :run_in_transaction_options
    set_callback :execute, :around, ->(_interaction, block) {
      ActiveRecord::Base.transaction(**run_in_transaction_options) do
        block.call
      end
    }, if: :run_in_transaction_options
  end

  class_methods do
    # https://pragtob.wordpress.com/2017/12/12/surprises-with-nested-transactions-rollbacks-and-activerecord/
    def run_in_transaction!(requires_new: true)
      self.run_in_transaction_options = {requires_new: requires_new}
    end

    def skip_run_in_transaction!
      self.run_in_transaction_options = nil
    end
  end
end
