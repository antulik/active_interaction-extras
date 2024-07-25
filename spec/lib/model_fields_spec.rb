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
      subject(:model_fields) do
        test_form_class.new(params).model_fields(:model)
      end
      let(:model) { double('Model', date_field: Date.today) }

      context "when model field is not given" do
        let(:params) { {model: model} }

        it 'returns values from given model' do
          expect(model_fields).to eq(date_field: Date.today)
        end
      end

      context 'with nil value for model field argument' do
        let(:params) { {model: model, date_field: nil} }

        it 'sets model field value to nil' do
          expect(model_fields).to eq(date_field: nil)
        end
      end

      context 'with empty string value for model field argument' do
        let(:params) { {model: model, date_field: ''} }

        it 'sets model field value to nil' do
          expect(model_fields).to eq(date_field: nil)
        end
      end
    end

    describe 'fields from model' do
      let(:model) { double('Model', date_field: Date.today) }

      context 'when interaction is initialized' do
        it 'prepopulates fields' do
          result = test_form_class.new(model: model)

          expect(result.date_field).to eq Date.today
        end
      end

      context 'when interaction is run' do
        it 'prepopulates model fields' do
          result = test_form_class.run!(model: model)

          expect(result).to eq Date.today
        end

        it 'sets to nil' do
          result = test_form_class.run!(model: model, date_field: nil)

          expect(result).to be_nil
        end

        it 'sets empty string to nil' do
          result = test_form_class.run!(model: model, date_field: '')

          expect(result).to be_nil
        end
      end
    end

    describe '#inputs.given?' do
      let(:model) { double('Model', date_field: Date.today) }

      it 'is true for given attribute' do
        form = test_form_class.new(model: model)

        expect(form.inputs.given?(:model)).to be true
      end

      it 'is false for prepopulated fields' do
        form = test_form_class.new(model: model)

        expect(form.inputs.given?(:date_field)).to be false
      end

      it 'is false for prepopulated fields when run' do
        form = test_form_class.run(model: model)

        expect(form.inputs.given?(:date_field)).to be false
      end
    end

    describe '#any_changed?' do
      it 'is false if value has not changed' do
        model = double('Model', date_field: Date.today, new_record?: false)
        form = test_form_class.new(model: model, date_field: Date.today)

        expect(form.any_changed?(:date_field)).to be false
      end

      it 'is true if new record' do
        model = double('Model', date_field: Date.today, new_record?: true)
        form = test_form_class.new(model: model, date_field: Date.today)

        expect(form.any_changed?(:date_field)).to be true
      end

      it 'is true when value changed' do
        model = double('Model', date_field: Date.today, new_record?: false)
        form = test_form_class.new(model: model, date_field: Date.tomorrow)

        expect(form.any_changed?(:date_field)).to be true
      end

      it 'is true when value is cleared' do
        model = double('Model', date_field: Date.today, new_record?: false)
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
