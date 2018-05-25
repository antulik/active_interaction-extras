module ActiveInteraction::Extras::All
  extend ActiveSupport::Concern

  include ActiveInteraction::Extras::Halt
  include ActiveInteraction::Extras::ModelFields
  include ActiveInteraction::Extras::RunCallback
  include ActiveInteraction::Extras::StrongParams
  include ActiveInteraction::Extras::Transaction
end
