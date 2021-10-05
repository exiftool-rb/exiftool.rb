# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'minitest/great_expectations'
require 'yaml'
require 'exiftool'
require 'simplecov-console'
require 'simplecov_json_formatter'

# We need a predictable timezone offset so non-tz-offset timestamps are comparable:
ENV['TZ'] = 'UTC'

unless ENV['CI']
  require 'minitest/reporters'
  Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::JSONFormatter
  ]
)

puts "Exiftool.exiftool_version = #{Exiftool.exiftool_version}"
