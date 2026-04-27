# frozen_string_literal: true

require 'test_helper'
require 'pathname'

# These are expected to be different on travis, due to different paths, filesystems, or
# exiftool version differences.
# fov and hyperfocal_distance, for example, are different between v8 and v9.
IGNORABLE_KEYS = %i[
  circle_of_confusion
  directory
  exif_tool_version
  file_access_date
  file_access_date_civil
  file_inode_change_date
  file_inode_change_date_civil
  file_modify_date
  file_modify_date_civil
  file_permissions
  file_size
  intelligent_contrast
  max_focal_length
  min_focal_length
  source_file
  thumbnail_image
  preview_tiff

].freeze

IGNORABLE_PATTERNS = [
  /.*-ml-\w\w-\w\w$/, # < translatable
  /35efl$/ # < 35mm Effective focal length, whose calculation was changed between v8 and v9.
].freeze

describe Exiftool do
  it 'returns a sensible version' do
    assert_match(/\A\d+\.\d+\z/, Exiftool.exiftool_version)
  end

  it 'returns true for exiftool installed' do
    assert_predicate(Exiftool, :exiftool_installed?)
  end

  it 'sets custom path for exiftool' do
    e = Exiftool.dup
    e.command = 'foo/bar/exiftool'

    assert_equal('foo/bar/exiftool', e.command)
  end

  it 'returns empty version for missing exiftool command' do
    e = Class.new(Exiftool)
    e.command = 'no/such/exiftool'

    assert_equal('', e.exiftool_version)
    refute_predicate(e, :exiftool_installed?)
  end

  it 'raises ExiftoolNotInstalled for missing exiftool command' do
    e = Class.new(Exiftool)
    e.command = 'no/such/exiftool'

    assert_raises(Exiftool::ExiftoolNotInstalled) { e.new('test/IMG_2452.jpg') }
  end

  it 'raises NoSuchFile for missing files' do
    assert_raises(Exiftool::NoSuchFile) { Exiftool.new('no/such/file') }
  end

  it 'raises NotAFile for directories' do
    assert_raises(Exiftool::NotAFile) { Exiftool.new('lib') }
  end

  it 'no-ops with no files' do
    e = Exiftool.new([])

    refute_predicate(e, :errors?)
  end

  it 'has errors with files without EXIF headers' do
    e = Exiftool.new('test/binary_file')

    assert_predicate(e, :errors?)
  end

  it 'returns results with error when explicitly asked' do
    e = Exiftool.new('test/binary_file')

    assert_predicate(e.results(include_results_with_errors: true), :any?)
  end

  it 'doesn\'t return results with errors' do
    e = Exiftool.new('test/binary_file')

    refute_predicate(e.results, :any?)
  end

  it 'supports a singular Pathname as a constructor arg' do
    e = Exiftool.new(Pathname.new('test/utf8.jpg'))
    validate_result(e, 'test/utf8.jpg')
  end

  it 'supports an IO object as a constructor arg' do
    File.open('test/IMG_2452.jpg', 'rb') do |io|
      e = Exiftool.new(io)
      h = e.to_hash

      refute_predicate(e, :errors?)
      assert_equal(
        { file_type: 'JPEG', mime_type: 'image/jpeg', make: 'Canon' },
        h.slice(:file_type, :mime_type, :make)
      )
    end
  end

  it 'supports a StringIO object as a constructor arg' do
    io = StringIO.new(File.binread('test/IMG_2452.jpg'))
    e = Exiftool.new(io)
    h = e.to_hash

    refute_predicate(e, :errors?)
    assert_equal(
      { file_type: 'JPEG', mime_type: 'image/jpeg', make: 'Canon' },
      h.slice(:file_type, :mime_type, :make)
    )
  end

  describe 'single-get' do
    it 'responds with known correct responses' do
      Dir['test/*.jpg'].each do |filename|
        e = Exiftool.new(filename)

        assert_equal(Exiftool.expand_path(filename), e[:source_file])
        validate_result(e, filename)
      end
      Dir['test/*.tif'].each do |filename|
        e = Exiftool.new(filename)

        assert_equal(Exiftool.expand_path(filename), e[:source_file])
        validate_result(e, filename)
      end
    end

    it 'fails if there are multiple files provided and Exiftool is treated as a result' do
      e = Exiftool.new(Dir['test/*.jpg'])

      assert_raises(Exiftool::NoDefaultResultWithMultiget) { e.to_hash[:source_file] }
      assert_raises(Exiftool::NoDefaultResultWithMultiget) { e[:source_file] }
      assert_raises(Exiftool::NoDefaultResultWithMultiget) { e.raw[:aperture] }
    end
  end

  describe 'multi-get' do
    it 'supports multi match results' do
      filenames = Dir['**/*.jpg'].to_a
      e = Exiftool.new(filenames)
      filenames.each { |f| validate_result(e.result_for(f), f) }
    end

    it 'returns list of files with results' do
      filenames = Dir['**/*.jpg'].to_a
      e = Exiftool.new(filenames)

      assert_equal(6, e.files_with_results.size)
    end
  end

  def validate_result(result, filename)
    basename = File.basename(filename)
    yaml_file = "test/expected/#{basename}.yaml"
    actual = result.to_hash.delete_if { |k, _v| ignorable_key?(k) }
    File.open(yaml_file, 'w') { |out| YAML.dump(actual, out) } if ENV['DUMP_RESULTS']
    expected = File.open(yaml_file) { |f| YAML.safe_load(f, permitted_classes: [Symbol, Date, Rational]) }
    expected.delete_if { |k, _v| ignorable_key?(k) }

    assert_equal(expected, actual)
  end

  puts "Ignoring #{IGNORABLE_KEYS.size} keys."

  def ignorable_key?(key)
    IGNORABLE_KEYS.include?(key) || IGNORABLE_PATTERNS.any? { |ea| key.to_s =~ ea }
  end
end
