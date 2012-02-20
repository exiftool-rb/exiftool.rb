require "test/unit"
require "exif_tooler"
require "yaml"

class TestExiftoolr < Test::Unit::TestCase

  DUMP_RESULTS = false

  def test_missing
    assert_raise ExifTooler::NoSuchFile do
      ExifTooler.new("no/such/file")
    end
  end

  def test_invalid_exif
    assert ExifTooler.new("Gemfile").errors?
  end

  def test_matches
    Dir["**/*.jpg"].each do |ea|
      e = ExifTooler.new(ea)
      assert !e.errors?
      d = e.to_hash
      yaml_file = "#{ea}.yaml"
      File.open(yaml_file, 'w') { |out| YAML.dump(d, out) } if DUMP_RESULTS
      e = File.open(yaml_file) { |yf| YAML::load(yf) }
      d.keys.each do |k|
        assert_equal d[k], e[k], "#{k}: #{d[k].inspect} != #{e[k].inspect }"
      end
    end
  end
end
