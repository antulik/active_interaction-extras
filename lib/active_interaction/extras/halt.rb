module ActiveInteraction::Extras::Halt
  extend ActiveSupport::Concern

  THROW_OBJECT = Object.new.freeze
  private_constant :THROW_OBJECT

  included do
    set_callback :execute, :around, lambda { |_interaction, block|
      catch THROW_OBJECT do
        block.call
      end
    }
  end

  def halt!
    throw THROW_OBJECT, errors
  end

  def halt_if_errors!
    halt! if errors.any?
  end
end
