require 'minitest/autorun'
require 'minitest/great_expectations'
require 'yaml'
require 'exiftoolr'

unless ENV['CI']
  require 'minitest/reporters'
  MiniTest::Reporters.use!
end
