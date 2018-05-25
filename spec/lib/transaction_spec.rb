RSpec.describe ActiveInteraction::Extras::Transaction do
  xdescribe 'run_in_transaction!' do
    let(:klass) do
      Class.new(TestableService) do
        interface :x
        run_in_transaction!

        def execute
          compose self.class.composable_class, x: x
        end

        def self.composable_class
          Class.new(TestableService) do
            interface :x

            def execute
              x.save
              errors.add :base, 'nope'
            end
          end
        end
      end
    end

    context 'composable interactions' do
      it 'rollbacks when composable failed' do
        group = create(:exclusive_group)

        group.name = 'changed_name'
        outcome = klass.run(x: group)

        expect(outcome).to be_invalid
        group.reload
        expect(group.name).to_not eq 'changed_name'
      end
    end
  end
end
