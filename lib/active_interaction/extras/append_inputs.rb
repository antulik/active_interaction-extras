module ActiveInteraction::Extras::AppendInputs
  extend ActiveSupport::Concern

  module InputsRefinement
    refine ActiveInteraction::Inputs do
      # Based on ActiveInteraction::Inputs#initialize
      def append(raw_inputs, overwrite: false)
        new_normalized_inputs = normalize(raw_inputs)

        keys = new_normalized_inputs.keys.map(&:to_sym)
        keys = keys.reject { given?(_1) } if !overwrite

        new_inputs = @base.class.filters
          .slice(*keys)
          .each_with_object({}) do |(name, filter), inputs|
          inputs[name] = filter.process(new_normalized_inputs[name], @base)

          yield(name, inputs[name]) if block_given?
        end

        @normalized_inputs = @normalized_inputs.merge(new_normalized_inputs)
        @inputs = @inputs.merge(new_inputs)
        @to_h = nil
      end
    end
  end

  using InputsRefinement

  def default_inputs(*args)
    inputs.append(*args) do |name, input|
      public_send("#{name}=", input.value)
    end
  end

  # def default_input(name, &block)
  #   if !inputs.given?(name)
  #     default_inputs(name: block.call)
  #   end
  # end

  class_methods do
    def default_inputs(&block)
      after_initialize do
        hash = block.call
        default_inputs(hash)
      end
    end

    def default_input(name, &block)
      after_initialize do
        default_inputs(name => instance_exec(&block))
      end
    end
  end
end
