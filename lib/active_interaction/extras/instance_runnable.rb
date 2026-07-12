# Allows Interaction.new.run
# Useful for controllers, so single object could be instantiated for new, create, edit, update
# @example
#   def form
#     @form ||= Form.new(record:, params:)
#   end
#
#   def create
#     if form.save
#       ...
#     else
#       ...
#     end
#   end
#
module ActiveInteraction::Extras::InstanceRunnable
  extend ActiveSupport::Concern

  def save
    run
    valid?
  end

  def save!
    run!
  end

  def run
    if @_executed
      raise("Service already executed")
    end
    @_executed = true
    super
  end
end
