# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "grack/version"

Gem::Specification.new do |s|
  s.name        = "grack"
  s.version     = Grack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Scott Chacon"]
  s.email       = ["schacon@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/grack"
  s.summary     = %q{Git Smart HTTP Server Rack Implementation}
  s.description = %q{}

  s.rubyforge_project = "grack"
  s.add_dependency "rack"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
