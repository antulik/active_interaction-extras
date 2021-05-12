require 'active_interaction/extras/filter_extensions/timezone_support'

RSpec.describe ActiveInteraction::Extras::FilterExtensions::TimezoneSupport do
  before do
    stub_const(
      'TestService',
      Class.new(ActiveInteraction::Base) do
        time :epoch

        def execute
          epoch.iso8601
        end
      end
    )
  end

  it 'parses time in the explicit timezone' do
    Time.use_zone('Bangkok') do
      expect(TestService.run!(epoch: '2000-12-11 10:30')).to eq(
        '2000-12-11T10:30:00+07:00',
      )
    end
  end

  it 'parses time in system timezone when timezone is not explicit' do
    with_env 'TZ' => 'Australia/Darwin' do
      expect(Time).to receive(:zone).and_return(nil).at_least(1)
      expect(TestService.run!(epoch: '2000-12-11 10:30')).to eq(
        '2000-12-11T10:30:00+09:30',
      )
    end
  end
end
