RSpec.describe ActiveInteraction::Extras::Transaction do
  before do
    require 'active_record'

    ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

    ActiveRecord::Schema.define do
      self.verbose = false

      create_table :users, :force => true do |t|
        t.string :name
        t.timestamps
      end
    end

    stub_const('User', Class.new(ActiveRecord::Base))
  end

  describe 'run_in_transaction!' do
    before do
      stub_const('ServiceB', Class.new(TestableService) do
        object :user

        def execute
          user.save!
          errors.add :base, 'nope'
        end
      end)

      stub_const('ServiceA', Class.new(TestableService) do
        object :user
        run_in_transaction!

        def execute
          user.name = 'changed_name'
          compose ServiceB, user: user
        end
      end)
    end

    context 'composable interactions' do
      it 'rollbacks when composable failed' do
        user = User.create!(name: 'name')

        outcome = ServiceA.run(user: user)

        expect(outcome).to be_invalid
        expect(user.reload.name).to eq 'name'
      end
    end

    describe 'skip_run_in_transaction!' do
      before do
        stub_const('ServiceNoTransaction', Class.new(ServiceA) do
          skip_run_in_transaction!
        end)
      end

      it 'does not run in transaction' do
        user = User.create!(name: 'name')

        outcome = ServiceNoTransaction.run(user: user)

        expect(outcome).to be_invalid
        expect(user.reload.name).to eq 'changed_name'
      end
    end
  end
end
