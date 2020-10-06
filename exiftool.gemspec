# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$:.unshift(lib) unless $:.include?(lib)
require 'exiftool/version'

Gem::Specification.new do |spec|
  spec.name        = 'exiftool'
  spec.version     = Exiftool::VERSION
  spec.authors     = ['Matthew McEachen']
  spec.email       = %w[matthew-github@mceachen.org]
  spec.homepage    = 'https://github.com/mceachen/exiftool.rb'
  spec.summary     = 'Multiget ExifTool wrapper for ruby'
  spec.description = 'Multiget ExifTool wrapper for ruby'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 2.4'

  spec.files         = `git ls-files -- lib`.split($/)
  spec.require_paths = %w[lib]

  spec.requirements << 'ExifTool (see http://www.sno.phy.queensu.ca/~phil/exiftool/)'

  spec.add_dependency 'json'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-great_expectations'
  spec.add_development_dependency 'minitest-reporters' unless ENV['CI']
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov', '~> 0.17.1'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'yard'
end
