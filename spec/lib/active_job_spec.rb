require 'global_id'

RSpec.describe ActiveInteraction::Extras::ActiveJob do
  include ActiveJob::TestHelper

  before do
    stub_const('GlobalIdClass', Class.new do
      include GlobalID::Identification
      attr_reader :id

      def initialize(id)
        @id = id
      end

      def self.find(*)
        raise
      end
    end)

    stub_const('WithJob', Class.new(TestableService) do
      include ActiveInteraction::Extras::ActiveJob
    end)

    stub_const('WithJob::Job', Class.new(ActiveJob::Base) do
      include ActiveInteraction::Extras::ActiveJob::Perform
    end)

    stub_const('DelayForm', Class.new(WithJob) do
      anything :some_object

      def execute
        some_object
      end
    end)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe '#delay' do
    it 'serializes objects' do
      obj = GlobalIdClass.new(2)
      DelayForm.delay.run(some_object: obj)

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
      obj = GlobalIdClass.new(2)
      expect(GlobalIdClass).to receive(:find).with('2').and_return(obj)

      result = DelayForm::Job.execute(
        {
          'job_class' => DelayForm::Job.name,
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
