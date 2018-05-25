RSpec.describe ActiveInteraction::Extras::Halt do
  shared_examples 'halt' do
    it 'stops the execution' do
      result = klass.run!

      expect(result).to be_nil
    end
  end

  describe '#halt!' do
    context 'within execute' do
      let(:klass) do
        Class.new(TestableService) do
          def execute
            halt!
            123
          end
        end
      end

      it_behaves_like 'halt'

    end

    context 'within non execute method' do
      let(:klass) do
        Class.new(TestableService) do
          def execute
            other_method
            123
          end

          def other_method
            halt!
          end
        end
      end

      it_behaves_like 'halt'
    end
  end

  describe '#halt_if_errors!' do
    let(:klass) do
      Class.new(TestableService) do
        def execute
          other_method
          123
        end

        def other_method
          halt!
        end
      end
    end
  end
end
