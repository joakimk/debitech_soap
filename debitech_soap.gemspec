# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "debitech_soap/version"

Gem::Specification.new do |s|
  s.name        = "debitech_soap"
  s.version     = DebitechSoap::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joakim Kolsjö"]
  s.email       = ["joakim.kolsjo@gmail.com"]
  s.homepage    = "http://github.com/joakimk/debitech_soap"
  s.summary     = %q{A pure ruby way to make payments with DebiTech}
  s.description = %q{An implementation of the DebiTech Java API using pure ruby and the SOAP API.}

  s.rubyforge_project = "debitech_soap"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
