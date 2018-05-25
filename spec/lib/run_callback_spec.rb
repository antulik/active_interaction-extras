RSpec.describe ActiveInteraction::Extras::RunCallback do
  describe 'run callbacks' do
    let(:test_class) do
      Class.new(TestableService) do
        interface :x
        boolean :with_presence, default: false
        boolean :with_execute_error, default: false

        validates :x, presence: true, if: :with_presence

        after_run do
          x.after_run_block
        end

        after_run :after_run_method

        after_successful_run do
          x.after_successful_run
        end

        after_failed_run do
          x.after_failed_run
        end

        def execute
          x.execute
          errors.add :base, 'error' if with_execute_error
        end

        def self.name
          'TestClass'
        end

        def after_run_method
          x.after_run_method
        end
      end
    end

    describe '#after_run' do
      it 'is called after execute method' do
        x = spy
        test_class.run!(x: x)

        expect(x).to have_received(:execute).ordered
        expect(x).to have_received(:after_run_block).ordered
      end

      it 'runs on failure' do
        x = spy
        outcome = test_class.run(x: x, with_presence: true)

        expect(outcome).to be_invalid
        expect(x).to_not have_received(:execute)
        expect(x).to have_received(:after_run_block).ordered
      end

      it 'works when used with symbol' do
        x = spy
        test_class.run!(x: x)

        expect(x).to have_received(:execute).ordered
        expect(x).to have_received(:after_run_method).ordered
      end
    end

    describe '#after_successful_run' do
      it 'does not run on failure' do
        x = spy
        outcome = test_class.run(x: x, with_execute_error: true)

        expect(outcome).to be_invalid
        expect(x).to_not have_received(:after_successful_run)
      end

      it 'runs on success' do
        x = spy
        outcome = test_class.run(x: x)

        expect(outcome).to be_valid
        expect(x).to have_received(:after_successful_run)
      end
    end

    describe '#after_failed_run' do
      it 'runs on failure' do
        x = spy
        outcome = test_class.run(x: x, with_execute_error: true)

        expect(outcome).to be_invalid
        expect(x).to have_received(:after_failed_run)
      end

      it 'does not run on success' do
        x = spy
        outcome = test_class.run(x: x)

        expect(outcome).to be_valid
        expect(x).to_not have_received(:after_failed_run)
      end
    end
  end
end
