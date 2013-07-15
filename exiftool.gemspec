# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exiftool/version'

Gem::Specification.new do |spec|
  spec.name        = 'exiftool'
  spec.version     = Exiftool::VERSION
  spec.authors     = ['Matthew McEachen']
  spec.email       = %w(matthew-github@mceachen.org)
  spec.homepage    = 'https://github.com/mceachen/exiftoolr'
  spec.summary     = %q{Multiget ExifTool wrapper for ruby}
  spec.description = %q{Multiget ExifTool wrapper for ruby}
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.requirements << 'ExifTool (see http://www.sno.phy.queensu.ca/~phil/exiftool/)'

  spec.add_dependency 'json'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-great_expectations'
  spec.add_development_dependency 'minitest-reporters' unless ENV['CI']
end
