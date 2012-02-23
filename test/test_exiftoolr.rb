require "test/unit"
require "exiftoolr"
require "yaml"

class TestExiftoolr < Test::Unit::TestCase

  DUMP_RESULTS = false

  def test_missing
    assert_raise Exiftoolr::NoSuchFile do
      Exiftoolr.new("no/such/file")
    end
  end

  def test_invalid_exif
    assert Exiftoolr.new("Gemfile").errors?
  end

  def test_matches
    Dir["**/*.jpg"].each do |filename|
      e = Exiftoolr.new(filename)
      validate_result(e, filename)
    end
  end

  def validate_result(result, filename)
    assert !result.errors?
    yaml_file = "#{filename}.yaml"
    exif = result.to_hash
    File.open(yaml_file, 'w') { |out| YAML.dump(exif, out) } if DUMP_RESULTS
    e = File.open(yaml_file) { |f| YAML::load(f) }
    exif.keys.each do |k|
      assert_equal e[k], exif[k], "Key '#{k}' was incorrect for #{filename}"
    end
  end

  def test_multi_matches
    filenames = Dir["**/*.jpg"].to_a
    e = Exiftoolr.new(filenames)
    filenames.each { |f| validate_result(e.result_for(f), f) }
  end
end
