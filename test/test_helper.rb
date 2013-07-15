require 'minitest/autorun'
require 'minitest/great_expectations'
require 'yaml'
require 'Exiftool'

# We need a predictable timezone offset so non-tz-offset timestamps are comparable:
ENV['TZ'] = 'UTC'

unless ENV['CI']
  require 'minitest/reporters'
  MiniTest::Reporters.use!
end

puts "Exiftool.exiftool_version = #{Exiftool.exiftool_version}"
