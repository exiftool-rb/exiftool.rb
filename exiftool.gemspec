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

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 3.0'

  spec.files         = `git ls-files -- lib`.split($/)
  spec.require_paths = %w[lib]

  spec.requirements << 'ExifTool (see http://exiftool.org)'

  spec.add_dependency 'json'
end
