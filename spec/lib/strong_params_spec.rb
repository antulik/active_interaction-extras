require "action_controller"

RSpec.describe ActiveInteraction::Extras::StrongParams do
  describe 'strong params' do
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
  end
end
