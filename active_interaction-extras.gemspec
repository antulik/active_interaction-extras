
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_interaction/extras/version"

Gem::Specification.new do |spec|
  spec.name          = "active_interaction-extras"
  spec.version       = ActiveInteraction::Extras::VERSION
  spec.authors       = ["Anton Katunin"]
  spec.email         = ["antulik@gmail.com"]

  spec.summary       = %q{Extension for active_interaction gem}
  spec.description   = %q{Extension for active_interaction gem}
  spec.homepage      = "https://github.com/antulik/xxxx"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "active_interaction", ">= 3.0.0"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_dependency "activesupport", "~> 3.7"
end
