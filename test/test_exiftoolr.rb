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

  def test_directory
    assert_raise Exiftoolr::NotAFile do
      Exiftoolr.new("lib")
    end
  end

  def test_no_files
    assert !Exiftoolr.new([]).errors?
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
    yaml_file = "#{filename}.yaml"
    if File.exist?(yaml_file)
      assert !result.errors?
    else
      assert result.errors?
      return
    end
    exif = result.to_hash
    File.open(yaml_file, 'w') { |out| YAML.dump(exif, out) } if DUMP_RESULTS
    e = File.open(yaml_file) { |f| YAML::load(f) }
    exif.keys.each do |k|
      next if ignorable_key?(k)
      expected = e[k]
      actual = exif[k]
      if actual.is_a?(String)
        expected.downcase!
        actual.downcase!
      end
      assert_equal expected, actual, "Key '#{k}' was incorrect for #{filename}"
    end
  end

  TRANSLATED_KEY = /.*\-ml-\w\w-\w\w$/

  def ignorable_key? key
    @ignorable_keys ||= begin
      ignorable = [:file_modify_date, :directory, :source_file, :exif_tool_version]
      ignorable += [:modify_date, :create_date, :date_time_original, :nd_filter] if Exiftoolr.exiftool_version <= 8.2
      ignorable
    end.include?(key) || key.to_s =~ TRANSLATED_KEY
  end

  def test_multi_matches
    filenames = Dir["**/*.jpg"].to_a
    e = Exiftoolr.new(filenames)
    filenames.each { |f| validate_result(e.result_for(f), f) }
  end

  def test_error_filtering
    filenames = Dir["**/*.*"].to_a
    e = Exiftoolr.new(filenames)
    expected_files = Dir["**/*.jpg"].to_a.collect { |f| File.expand_path(f) }.sort
    assert_equal expected_files, e.files_with_results.sort
    filenames.each { |f| validate_result(e.result_for(f), f) }
  end
end
