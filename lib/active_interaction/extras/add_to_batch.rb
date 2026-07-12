module ActiveInteraction::Extras::AddToBatch
  extend ActiveSupport::Concern

  include ActiveInteraction::Extras::Current

  def add_to_batch(&block)
    if current.batch
      current.batch.add(&block)
    else
      block.call
    end
  end
end
