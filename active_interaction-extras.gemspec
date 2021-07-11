
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_interaction/extras/version"

Gem::Specification.new do |spec|
  spec.name          = "active_interaction-extras"
  spec.version       = ActiveInteraction::Extras::VERSION
  spec.authors       = ["Anton Katunin"]
  spec.email         = ["antulik@gmail.com"]

  spec.summary       = %q{Extensions for active_interaction gem}
  spec.description   = %q{Extensions for active_interaction gem}
  spec.homepage      = "https://github.com/antulik/active_interaction-extras"
  spec.license       = "MIT"
  spec.metadata    = {
    "changelog_uri" => "https://github.com/antulik/active_interaction-extras/blob/master/CHANGELOG.md",
  }

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "active_interaction", ">= 4.0.2"
  spec.add_dependency "activemodel", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"

  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "activerecord"
end
