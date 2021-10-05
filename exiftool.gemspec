# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$:.unshift(lib) unless $:.include?(lib)
require 'exiftool/version'

Gem::Specification.new do |spec|
  spec.name        = 'exiftool'
  spec.version     = Exiftool::VERSION
  spec.authors     = ['Matthew McEachen', 'Sergey Morozov']
  spec.email       = %w[matthew+github@mceachen.org morozgrafix@gmail.com]
  spec.homepage    = 'https://github.com/exiftool-rb/exiftool.rb'
  spec.summary     = 'Multiget ExifTool wrapper for ruby'
  spec.description = 'Multiget ExifTool wrapper for ruby'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 2.4'

  spec.files         = `git ls-files -- lib`.split($/)
  spec.require_paths = %w[lib]

  spec.requirements << 'ExifTool (see http://exiftool.org)'

  spec.add_dependency 'json'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-great_expectations'
  spec.add_development_dependency 'minitest-reporters' unless ENV['CI']
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'yard'
end
