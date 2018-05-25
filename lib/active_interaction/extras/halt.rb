module ActiveInteraction::Extras::Halt
  extend ActiveSupport::Concern

  included do
    set_callback :execute, :around, lambda { |_interaction, block|
      catch :strict_error do
        block.call
      end
    }
  end

  def halt!
    throw :strict_error, errors
  end

  def halt_if_errors!
    halt! if errors.any?
  end
end
