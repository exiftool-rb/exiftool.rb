require 'minitest/autorun'
require 'minitest/great_expectations'
require 'yaml'
require 'exiftoolr'

# We need a predictable timezone offset so non-tz-offset timestamps are comparable:
ENV['TZ'] = 'UTC'

unless ENV['CI']
  require 'minitest/reporters'
  MiniTest::Reporters.use!
end
