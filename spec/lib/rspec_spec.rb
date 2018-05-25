RSpec.describe ActiveInteraction::Extras::Rspec do
  include described_class

  let(:without_inputs) do
    Class.new(TestableService) do
      def execute
        raise 'This should never be called'
      end
    end
  end

  let(:int_input) do
    Class.new(TestableService) do
      integer :x

      def execute
        raise 'This should never be called'
      end

      def self.name
        'TestClass'
      end
    end
  end

  describe '#expect_to_execute' do
    it 'works with #run' do
      expect_to_execute(without_inputs)

      outcome = without_inputs.run
      expect(outcome).to be_valid
      expect(outcome.result).to be_nil
    end

    it 'works with #run!' do
      expect_to_execute(without_inputs)

      result = without_inputs.run!
      expect(result).to be_nil
    end

    it 'works with :return option' do
      expect_to_execute(without_inputs, return: :asd)

      result = without_inputs.run!
      expect(result).to eq :asd
    end

    it 'works with :with and :return options' do
      expect_to_execute(int_input, with: [{ x: 1 }], return: 2)
      expect_to_execute(int_input, with: [{ x: 3 }], return: 4)

      expect(int_input.run!(x: 3)).to eq 4
      expect(int_input.run!(x: 1)).to eq 2
    end

    it 'works with :fail option' do
      expect_to_execute(without_inputs)
      outcome = without_inputs.run
      expect(outcome).to be_valid

      expect_to_execute(without_inputs, fail: true)
      outcome = without_inputs.run
      expect(outcome).to be_invalid
    end
  end

  describe '#expect_to_run' do
    it 'works with #run' do
      expect_to_run(without_inputs)

      outcome = without_inputs.run
      expect(outcome).to be_valid
      expect(outcome.result).to be_nil
    end

    it 'works with #run!' do
      expect_to_run(without_inputs)

      result = without_inputs.run!
      expect(result).to be_nil
    end

    it 'works with :return option' do
      expect_to_run(without_inputs, return: :asd)

      result = without_inputs.run!
      expect(result).to eq :asd
    end

    it 'works with :with and :return options' do
      expect_to_run(int_input, with: [{ x: 1 }], return: 2)
      expect_to_run(int_input, with: [{ x: 3 }], return: 4)

      expect(int_input.run!(x: 3)).to eq 4
      expect(int_input.run!(x: 1)).to eq 2
    end

    it 'works with :fail option' do
      expect_to_run(without_inputs)
      outcome = without_inputs.run
      expect(outcome).to be_valid

      expect_to_run(without_inputs, fail: true)
      outcome = without_inputs.run
      expect(outcome).to be_invalid
    end

    it 'does not validate input type' do
      expect_to_run(int_input)

      outcome = int_input.run(x: double('Some invalid input type'))
      expect(outcome).to be_valid
    end
  end
end
