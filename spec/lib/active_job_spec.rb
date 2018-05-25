require 'global_id'

RSpec.describe ActiveInteraction::Extras::ActiveJob do
  include ActiveJob::TestHelper

  class self::GlobalIdClass
    include GlobalID::Identification
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def self.find(*)
      raise
    end
  end

  class self::DelayForm < TestableService
    interface :some_object

    def execute
      some_object
    end
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe '#delay' do
    it 'serializes objects' do
      obj = self.class::GlobalIdClass.new(2)
      self.class::DelayForm.delay.run(some_object: obj)

      expect(ActiveJob::Base.queue_adapter.enqueued_jobs).to include(
        hash_including(
          :job,
          :args => [{
            "some_object" => { "_aj_globalid" => obj.to_gid.to_s },
            "_aj_symbol_keys" => ["some_object"]
          }],
          :queue => "default"
        )
      )
    end

    it 'deserializes objects' do
      obj = self.class::GlobalIdClass.new(2)
      expect(self.class::GlobalIdClass).to receive(:find).with('2').and_return(obj)

      result = self.class::DelayForm::Job.execute(
        {
          'job_class' => self.class::DelayForm::Job.name,
          'arguments' => [{
            "some_object" => {
              "_aj_globalid" => obj.to_gid.to_s },
            "_aj_symbol_keys" => ["some_object"]
          }],
          'queue' => "default"
        }
      )

      expect(result).to eq obj
    end
  end
end
