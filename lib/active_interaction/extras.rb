require "active_interaction/extras/version"

require 'active_support'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/module/concerning'

require 'active_interaction'

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem_extension(ActiveInteraction)
loader.inflector.inflect(
  'uuid_filter' => 'UUIDFilter',
)
loader.setup

module ActiveInteraction
  module Extras

  end
end

require 'active_interaction/extras/filters/anything_filter'
require 'active_interaction/extras/filters/ar_relation_filter'
require 'active_interaction/extras/filters/uuid_filter'

I18n.load_path.unshift(
  *Dir.glob(
    File.expand_path(
      File.join(%w[extras locale *.yml]), File.dirname(__FILE__)
    )
  )
)
