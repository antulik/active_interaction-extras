require 'action_controller'

RSpec.describe ActiveInteraction::Extras::FormParams do
  let(:klass) do
    Class.new(ActiveInteraction::Base) do
      extend ActiveModel::Naming

      include ActiveInteraction::Extras::FormParams

      string :permitted, permit: true, default: nil
      string :not_permitted, default: nil

      def execute
      end

      def self.name
        'SomeForm'
      end
    end
  end

  describe '#form_attributes' do
    it 'returns permitted filter attributes' do
      form = klass.new(permitted: 'yes', not_permitted: 'no')

      expect(form.form_attributes).to be_permitted
      expect(form.form_attributes.to_h).to eq('permitted' => 'yes')
    end
  end

  describe '#to_params' do
    it 'wraps form attributes using the model parameter key' do
      form = klass.new(permitted: 'yes', not_permitted: 'no')

      expect(form.to_params(extra: 'value').fetch('some_form').to_h).to eq(
        'permitted' => 'yes',
        'extra' => 'value',
      )
    end
  end

  describe '.to_params' do
    it 'wraps the given attributes using the model parameter key' do
      expect(klass.to_params(permitted: 'yes')).to eq(
        'some_form' => { permitted: 'yes' },
      )
    end
  end
end
