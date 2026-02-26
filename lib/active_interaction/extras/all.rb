module ActiveInteraction::Extras::All
  extend ActiveSupport::Concern

  # order dependant, include first so around callback includes other modules
  include ActiveInteraction::Extras::NamedCallbacks
  include ActiveInteraction::Extras::AfterInitialize
  include ActiveInteraction::Extras::Transaction

  include ActiveInteraction::Extras::FilterAlias
  include ActiveInteraction::Extras::Halt
  include ActiveInteraction::Extras::ModelFields
  include ActiveInteraction::Extras::NestedAttributes
  include ActiveInteraction::Extras::RunCallback
  include ActiveInteraction::Extras::StrongParams
  include ActiveInteraction::Extras::Current

  include ActiveInteraction::Extras::FormFor
  include ActiveInteraction::Extras::InstanceRunnable
  include ActiveInteraction::Extras::InitializeWith
  include ActiveInteraction::Extras::IncludeErrors
  include ActiveInteraction::Extras::AllRunner
  include ActiveInteraction::Extras::AppendInputs
  include ActiveInteraction::Extras::FileBlobs

end
