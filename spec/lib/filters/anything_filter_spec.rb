require 'securerandom'

RSpec.describe ActiveInteraction::Extras::Filters::AnythingFilter do
  before do
    stub_const(
      'TestService',
      Class.new(ActiveInteraction::Base) do
        anything :something

        def execute
          something
        end
      end,
    )
  end

  it 'accepts anything' do
    expect(run!(something: nil)).to eq nil
    expect(run!(something: 'string')).to eq 'string'
    expect(run!(something: '')).to eq ''
    expect(run!(something: :symbol)).to eq :symbol
    expect(run!(something: 1)).to eq 1
    expect(run!(something: false)).to eq false
    expect(run!(something: true)).to eq true

    object = Object.new
    expect(run!(something: object)).to eq object
  end

  def run!(args)
    TestService.run!(args)
  end
end
