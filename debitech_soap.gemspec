# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "debitech_soap/version"

Gem::Specification.new do |s|
  s.name        = "debitech_soap"
  s.version     = DebitechSoap::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joakim Kolsjö", 'Niklas Holmgren', 'Henrik Nyh', 'Daniel Eriksson']
  s.email       = ["joakim.kolsjo@gmail.com", 'niklas.holmgren@bukowskis.com', 'henrik@barsoom.se']
  s.homepage    = "http://github.com/joakimk/debitech_soap"
  s.summary     = %q{A pure ruby way to make payments with DebiTech}
  s.description = %q{An implementation of the DebiTech Java API using pure ruby and the SOAP API.}

  # Earlier versions of HTTPClient may prefer SSLv3 as its ssl_version,
  # but 2014-10-15 Debitech started having issues with SSLv3, returning
  # "sslv3 alert handshake failure"
  # Probably because of changes to counter the "Poodle" vulnerability.
  # See: https://gist.github.com/henrik/321bb53dc7c236a6f4a0
  s.add_dependency "httpclient", ">= 2.4.0"

  s.add_dependency "mumboe-soap4r", "~> 1.5.8.4"

  s.add_development_dependency "rake"
  s.add_development_dependency 'rspec'
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
