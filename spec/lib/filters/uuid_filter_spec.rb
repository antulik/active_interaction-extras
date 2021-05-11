require 'securerandom'

RSpec.describe ActiveInteraction::Extras::Filters::UUIDFilter do
  before do
    stub_const(
      'TestService',
      Class.new(ActiveInteraction::Base) do
        uuid :id

        def execute
          id
        end
      end,
    )
  end

  it 'accepts uuid' do
    uuid = SecureRandom.uuid
    outcome = TestService.run(id: uuid)

    expect(outcome).to be_valid
    expect(outcome.result).to eq uuid
  end

  it 'does not accept invalid uuid' do
    outcome = TestService.run(id: 1)

    expect(outcome).to be_invalid
    expect(outcome.errors.full_messages).to include 'Id is not a valid UUID'
  end

  it 'does not accept invalid uuid' do
    outcome = TestService.run(id: 'asd')

    expect(outcome).to be_invalid
    expect(outcome.errors.full_messages).to include 'Id is not a valid UUID'
  end

  it 'does not accept empty string' do
    outcome = TestService.run(id: '')

    expect(outcome).to be_invalid
    expect(outcome.errors.full_messages).to include 'Id is required'
  end

  it 'does not accept nil value' do
    outcome = TestService.run(id: nil)

    expect(outcome).to be_invalid
    expect(outcome.errors.full_messages).to include 'Id is required'
  end

  context 'with nil default' do
    before do
      stub_const(
        'TestService',
        Class.new(ActiveInteraction::Base) do
          uuid :id, default: nil

          def execute
            id
          end
        end,
      )
    end

    it 'converts empty string to nil' do
      expect(TestService.run!(id: '')).to eq nil
    end
  end

  context 'with some default' do
    before do
      stub_const(
        'TestService',
        Class.new(ActiveInteraction::Base) do
          uuid :id, default: '7cb8f3bf-5d50-4fa0-bde6-aeb678f74a3d'

          def execute
            id
          end
        end,
      )
    end

    it 'converts empty string to default' do
      expect(TestService.run!(id: '')).to eq '7cb8f3bf-5d50-4fa0-bde6-aeb678f74a3d'
    end
  end
end
