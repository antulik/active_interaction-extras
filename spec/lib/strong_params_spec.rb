require "action_controller"

RSpec.describe ActiveInteraction::Extras::StrongParams do
  let(:klass) do
    Class.new(TestableService) do
      extend ActiveModel::Naming

      string :permitted, permit: true, default: nil
      string :not_permitted, default: nil

      def execute;
      end

      def self.name
        'SomeForm'
      end
    end
  end

  describe 'params input' do
    it 'accepts and assigns permitted params' do
      params = ActionController::Parameters.new(
        some_form: {
          permitted: 'yes',
          not_permitted: 'no',
        },
      )

      outcome = klass.run(
        params: params,
      )

      expect(outcome).to be_valid
      expect(outcome.permitted).to eq 'yes'
      expect(outcome.not_permitted).to be_nil
    end

    it 'ignores non strong params objects' do
      params = {
        some_form: {
          permitted: 'yes',
          not_permitted: 'no',
        },
      }

      outcome = klass.run(
        params: params,
      )

      expect(outcome).to be_valid
      expect(outcome.permitted).to be_nil
      expect(outcome.not_permitted).to be_nil
    end
  end

  describe 'form_params input' do
    it 'accepts and assigns permitted params' do
      params = ActionController::Parameters.new(
        some_form: {
          permitted: 'yes',
          not_permitted: 'no',
        },
      )

      outcome = klass.run(
        form_params: params[:some_form],
      )

      expect(outcome).to be_valid
      expect(outcome.permitted).to eq 'yes'
      expect(outcome.not_permitted).to be_nil
    end
  end

  context 'with action controller parameters as input' do
    before do
      stub_const(
        'ParentScope::TestService',
        Class.new(ActiveInteraction::Base) do
          integer :a, default: -2
          integer :b, default: -3

          def execute
            inputs.to_h
          end
        end,
      )
    end

    it 'respects permitted params' do
      params = ActionController::Parameters.new(a: 1, b: 2).permit(:a)
      expect(ParentScope::TestService.run!(params)).to eq(a: 1, b: -3)
    end

    it 'respects permitted params with merge' do
      params = ActionController::Parameters.new(a: 1, b: 2).permit(:a).merge(b: 4)
      expect(ParentScope::TestService.run!(params)).to eq(a: 1, b: 4)
    end

    it 'accepts all params when not explicitly permitted' do
      params = ActionController::Parameters.new(a: 1, b: 2)
      expect(ParentScope::TestService.run!(params)).to eq(a: 1, b: 2)
    end
  end

  context 'with invalid inputs object type' do
    it 'raises ArgumentError' do
      expect { klass.run(Object.new) }.to raise_error(ArgumentError)
    end
  end
end
