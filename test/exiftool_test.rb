require 'test_helper'

describe Exiftool do

  DUMP_RESULTS = false

  it 'returns a sensible version' do
    Exiftool.exiftool_version.must_match /\A\d+\.\d+\z/
  end

  it 'raises NoSuchFile for missing files' do
    proc { Exiftool.new('no/such/file') }.must_raise Exiftool::NoSuchFile
  end

  it 'raises NotAFile for directories' do
    proc { Exiftool.new('lib') }.must_raise Exiftool::NotAFile
  end

  it 'no-ops with no files' do
    e = Exiftool.new([])
    e.errors?.must_be_false
  end

  it 'has errors with files without EXIF headers' do
    e = Exiftool.new('Gemfile')
    e.errors?.must_be_true
  end

  describe 'single-get' do
    it 'responds with known correct responses' do
      Dir['test/*.jpg'].each do |filename|
        e = Exiftool.new(filename)
        e[:source_file].must_equal Exiftool.expand_path(filename)
        validate_result(e, filename)
      end
    end

    it 'fails if there are multiple files provided and Exiftool is treated as a result' do
      e = Exiftool.new(Dir['test/*.jpg'])
      proc { e.to_hash[:source_file] }.must_raise Exiftool::NoDefaultResultWithMultiget
      proc { e[:source_file] }.must_raise Exiftool::NoDefaultResultWithMultiget
      proc { e.raw[:aperture] }.must_raise Exiftool::NoDefaultResultWithMultiget
    end
  end

  describe 'multi-get' do
    def test_multi_matches
      filenames = Dir['**/*.jpg'].to_a
      e = Exiftool.new(filenames)
      filenames.each { |f| validate_result(e.result_for(f), f) }
    end
  end

  def validate_result(result, filename)
    yaml_file = "#{filename}.yaml"
    exif = result.to_hash
    File.open(yaml_file, 'w') { |out| YAML.dump(exif, out) } if DUMP_RESULTS
    e = File.open(yaml_file) { |f| YAML::load(f) }
    bad_keys = exif.keys.select do |k|
      next if ignorable_key?(k)
      expected = e[k]
      next if expected.nil? # older version of exiftool
      actual = exif[k]
      if expected.is_a?(String)
        expected.downcase!
        actual.downcase!
      end
      expected != actual
    end
    fail "#{filename}[#{bad_keys.join(',')}] didn't match" unless bad_keys.empty?
  end

  # These are expected to be different on travis, due to different paths, filesystems, or
  # exiftool version differences.
  # fov and hyperfocal_distance, for example, are different between v8 and v9.
  IGNORABLE_KEYS = [
    :circle_of_confusion,
    :create_date,
    :create_date_ymd,
    :date_time_original,
    :date_time_original_ymd,
    :directory,
    :exif_tool_version,
    :file_access_date,
    :file_access_date_ymd,
    :file_inode_change_date,
    :file_inode_change_date_ymd,
    :file_modify_date,
    :file_modify_date_ymd,
    :file_permissions,
    :fov,
    :hyperfocal_distance,
    :modify_date,
    :modify_date_ymd,
    :nd_filter,
    :source_file
  ]

  IGNORABLE_PATTERNS = [
    /.*\-ml-\w\w-\w\w$/, # < translatable
    /35efl$/ # < 35mm Effective focal length, whose calculation was changed between v8 and v9.
  ]

  def ignorable_key?(key)
    IGNORABLE_KEYS.include?(key) || IGNORABLE_PATTERNS.any? { |ea| key.to_s =~ ea }
  end
end
