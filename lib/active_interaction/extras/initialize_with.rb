module ActiveInteraction::Extras::InitializeWith
  extend ActiveSupport::Concern

  include ActiveInteraction::Extras::AfterInitialize

  class_methods do
    def initialize_with(&block)
      after_initialize do
        hash = instance_exec(&block)
        hash&.each do |filter_name, value|
          public_send "#{filter_name}=", value if !inputs.given?(filter_name)
        end
      end
    end
  end
end
