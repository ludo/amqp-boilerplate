# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require 'amqp/boilerplate/version'

Gem::Specification.new do |s|
  s.name        = "amqp-boilerplate"
  s.version     = AMQP::Boilerplate::VERSION
  s.authors     = ["Patrick Baselier", "Ludo van den Boom"]
  s.email       = ["patrick@kabisa.nl", "ludo@cubicphuse.nl"]
  s.homepage    = ""
  s.summary     = %q{Helper modules for quickly setting up AMQP producers/consumers}
  s.description = %q{Collection of modules that aid in setting up AMQP producers and consumers.}

  s.rubyforge_project = "amqp-boilerplate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake", "~> 0.9"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_runtime_dependency "amqp", "~> 0.8"
end
