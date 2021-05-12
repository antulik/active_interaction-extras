require "action_controller"

RSpec.describe ActiveInteraction::Extras::FilterExtensions::HashAutoStrip do
  context 'when block is not given' do
    before do
      stub_const(
        'ParentScope::TestService',
        Class.new(ActiveInteraction::Base) do
          hash :h

          def execute
            h
          end
        end,
      )
    end

    it 'accepts all hash keys' do
      hash = {a: 1, 'b' => 2, c: [:d], e: {f: nil}}
      expect(ParentScope::TestService.run!(h: hash)).to eq(hash.with_indifferent_access)
    end

    it 'accepts only permitted action controller params' do
      params = ActionController::Parameters.new(a: 1, b: 2).permit(:a)
      expect(ParentScope::TestService.run!(h: params)).to eq({a: 1}.with_indifferent_access)
    end

    it 'raises error when action controller params are unpermitted' do
      params = ActionController::Parameters.new(a: 1, b: 2)
      expect { ParentScope::TestService.run!(h: params) }.to raise_error(
        ActionController::UnfilteredParameters, 'unable to convert unpermitted parameters to hash'
      )
    end
  end

  context 'when block is given' do
    before do
      stub_const(
        'ParentScope::TestService',
        Class.new(ActiveInteraction::Base) do
          hash :h do
            anything :a
          end

          def execute
            h
          end
        end,
      )
    end

    it 'strips not listed keys' do
      hash = {a: 1, 'b' => 2, c: [:d], e: {f: nil}}
      expect(ParentScope::TestService.run!(h: hash)).to eq({a: 1}.with_indifferent_access)
    end

    it 'accepts only permitted action controller params' do
      params = ActionController::Parameters.new(a: 1, b: 2).permit(:a)
      expect(ParentScope::TestService.run!(h: params)).to eq({a: 1}.with_indifferent_access)
    end

    it 'raises error when action controller params are unpermitted' do
      params = ActionController::Parameters.new(a: 1, b: 2)
      expect { ParentScope::TestService.run!(h: params) }.to raise_error(
        ActionController::UnfilteredParameters, 'unable to convert unpermitted parameters to hash'
      )
    end
  end
end
