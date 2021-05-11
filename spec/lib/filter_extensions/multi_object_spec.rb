RSpec.describe ActiveInteraction::Extras::FilterExtensions::MultiObject do
  context 'with multiple classes' do
    before do
      stub_const('UserA', Class.new)
      stub_const('UserB', Class.new)

      stub_const(
        'TestService',
        Class.new(ActiveInteraction::Base) do
          object :user, class: [UserA, 'UserB']

          def execute
            user
          end
        end,
      )
    end

    it 'accepts all whitelisted classes' do
      user_a = UserA.new
      user_b = UserB.new

      expect(TestService.run!(user: user_a)).to eq user_a
      expect(TestService.run!(user: user_b)).to eq user_b
    end

    it 'does not accept class that is not listed' do
      outcome = TestService.run(user: double)

      expect(outcome).to be_invalid
      expect(outcome.errors.full_messages).to include 'User is not a valid object'
    end
  end

  context 'with converter and multiple classes' do
    before do
      stub_const('UserA', Class.new {
        def self.some_converter(*)
          ;
        end })
      stub_const('UserB', Class.new)

      stub_const(
        'TestService',
        Class.new(ActiveInteraction::Base) do
          object :user, class: [UserA, 'UserB'], converter: :some_converter

          def execute
            user
          end
        end,
      )
    end

    it 'uses first class as converter' do
      input_value = double
      converter_result = UserB.new
      expect(UserA).to receive(:some_converter).with(input_value).and_return(converter_result)

      expect(TestService.run!(user: input_value)).to eq converter_result
    end
  end

  context 'when class name does not exist' do
    before do
      stub_const(
        'TestService',
        Class.new(ActiveInteraction::Base) do
          object :user, class: ['UnknownClassName']

          def execute
            user
          end
        end,
      )
    end

    it 'raises error' do
      expect { TestService.run!(user: double) }.to raise_error(
        ActiveInteraction::InvalidNameError, 'class "UnknownClassName" does not exist'
      )
    end
  end
end
