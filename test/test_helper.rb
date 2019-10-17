require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'minitest/great_expectations'
require 'yaml'
require 'exiftool'
require 'simplecov-console'

# We need a predictable timezone offset so non-tz-offset timestamps are comparable:
ENV['TZ'] = 'UTC'

unless ENV['CI']
  require 'minitest/reporters'
  Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(color: true)]
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ]
)

puts "Exiftool.exiftool_version = #{Exiftool.exiftool_version}"

def newer_exiftool?
  Exiftool.exiftool_version.to_f >= 9.99
end

