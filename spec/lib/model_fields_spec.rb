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
      context 'new object' do
        it 'prepopulates fields' do
          model = double('Model', date_field: Date.today)
          result = test_form_class.new(model: model)

          expect(result.date_field).to eq Date.today
        end
      end

      it 'prepopulates model fields' do
        model = double('Model', date_field: Date.today)
        result = test_form_class.run!(model: model)

        expect(result).to eq Date.today
      end

      it 'sets to nil' do
        model = double('Model', date_field: Date.today)
        result = test_form_class.run!(model: model, date_field: nil)

        expect(result).to be_nil
      end

      it 'sets empty string to nil' do
        model = double('Model', date_field: Date.today)
        result = test_form_class.run!(model: model, date_field: '')

        expect(result).to be_nil
      end
    end

    describe '#given?' do
      it 'is true for given attribute' do
        model = double('Model', date_field: Date.today)
        form = test_form_class.new(model: model)

        expect(form.inputs.given?(:model)).to be true
      end

      it 'is false for prepopulated fields' do
        model = double('Model', date_field: Date.today)
        form = test_form_class.new(model: model)

        expect(form.inputs.given?(:date_field)).to be false
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
