RSpec.describe ActiveInteraction::Extras::ModelFields do
  context 'simple form' do
    let(:test_form_class) do
      Class.new(TestableService) do
        anything :model

        model_fields :model, default: nil do
          date :date_field
        end

        def execute
          date_field
        end
      end
    end

    describe '#model_fields' do
      subject(:model_fields) { interaction.model_fields(:model) }

      let(:interaction) { test_form_class.new(**interaction_args) }
      let(:interaction_args) { {model: model} }
      let(:model) { double('Model', date_field: Date.today) }

      it 'returns values from given model' do
        expect(model_fields).to eq(date_field: Date.today)
      end

      context 'with nil value for model field argument' do
        let(:interaction_args) { {model: model, date_field: nil} }

        it 'sets model field value to nil' do
          expect(model_fields).to eq(date_field: nil)
        end
      end

      context 'with empty string value for model field argument' do
        let(:interaction_args) { {model: model, date_field: ''} }

        it 'sets model field value to nil' do
          expect(model_fields).to eq(date_field: nil)
        end
      end
    end

    describe '#given?' do
      it 'is true for given attribute' do
        model = double('Model', date_field: Date.today)
        form = test_form_class.new(model: model)

        expect(form.given?(:model)).to be true
      end

      it 'is false for prepopulated fields' do
        model = double('Model', date_field: Date.today)
        form = test_form_class.new(model: model)

        expect(form.given?(:date_field)).to be false
      end
    end

    describe '#any_changed?' do
      it 'is false if value has not changed' do
        model = double('Model', date_field: Date.today)
        form = test_form_class.new(model: model, date_field: Date.today)

        expect(form.any_changed?(:date_field)).to be false
      end

      it 'is true when value changed' do
        model = double('Model', date_field: Date.today)
        form = test_form_class.new(model: model, date_field: Date.tomorrow)

        expect(form.any_changed?(:date_field)).to be true
      end

      it 'is true when value is cleared' do
        model = double('Model', date_field: Date.today)
        form = test_form_class.new(model: model, date_field: nil)

        expect(form.any_changed?(:date_field)).to be true
      end
    end
  end

  context 'nested models' do
    let(:test_nested_form) do
      Class.new(TestableService) do
        anything :model_a
        anything :model_b, default: -> { model_a.b }

        model_fields :model_b, default: nil do
          date :date_field
        end

        def execute
          date_field
        end
      end
    end

    context 'new object' do
      it 'prepopulates values' do
        b = double('B', date_field: Date.today)
        a = double('A', b: b)
        result = test_nested_form.new(model_a: a)

        expect(result.date_field).to eq Date.today
      end
    end

    it 'prepopulates values' do
      b = double('B', date_field: Date.today)
      a = double('A', b: b)
      result = test_nested_form.run!(model_a: a)

      expect(result).to eq Date.today
    end
  end
end
