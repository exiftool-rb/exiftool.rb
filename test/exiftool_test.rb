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
    _(Exiftool.exiftool_version).must_match(/\A\d+\.\d+\z/)
  end

  it 'returns true for exiftool installed' do
    _(Exiftool.exiftool_installed?).must_be_true
  end

  it 'sets custom path for exiftool' do
    e = Exiftool.dup
    e.command = 'foo/bar/exiftool'
    _(e.command).must_match('foo/bar/exiftool')
  end

  it 'raises NoSuchFile for missing files' do
    _ { Exiftool.new('no/such/file') }.must_raise Exiftool::NoSuchFile
  end

  it 'raises NotAFile for directories' do
    _ { Exiftool.new('lib') }.must_raise Exiftool::NotAFile
  end

  it 'no-ops with no files' do
    e = Exiftool.new([])
    _(e.errors?).must_be_false
  end

  it 'has errors with files without EXIF headers' do
    e = Exiftool.new('test/binary_file')
    _(e.errors?).must_be_true
  end

  it 'returns results with error when explicitly asked' do
    e = Exiftool.new('test/binary_file')
    _(e.results(include_results_with_errors: true).any?).must_be_true
  end

  it 'doesn\'t return results with errors' do
    e = Exiftool.new('test/binary_file')
    _(e.results.any?).must_be_false
  end

  it 'supports a singular Pathname as a constructor arg' do
    e = Exiftool.new(Pathname.new('test/utf8.jpg'))
    validate_result(e, 'test/utf8.jpg')
  end

  it 'supports an IO object as a constructor arg' do
    File.open('test/IMG_2452.jpg', 'rb') do |io|
      e = Exiftool.new(io)
      _(e.errors?).must_be_false
      h = e.to_hash
      _(h[:file_type]).must_equal 'JPEG'
      _(h[:mime_type]).must_equal 'image/jpeg'
      _(h[:make]).must_equal 'Canon'
    end
  end

  describe 'single-get' do
    it 'responds with known correct responses' do
      Dir['test/*.jpg'].each do |filename|
        e = Exiftool.new(filename)
        _(e[:source_file]).must_equal Exiftool.expand_path(filename)
        validate_result(e, filename)
      end
      Dir['test/*.tif'].each do |filename|
        e = Exiftool.new(filename)
        _(e[:source_file]).must_equal Exiftool.expand_path(filename)
        validate_result(e, filename)
      end
    end

    it 'fails if there are multiple files provided and Exiftool is treated as a result' do
      e = Exiftool.new(Dir['test/*.jpg'])
      _ { e.to_hash[:source_file] }.must_raise Exiftool::NoDefaultResultWithMultiget
      _ { e[:source_file] }.must_raise Exiftool::NoDefaultResultWithMultiget
      _ { e.raw[:aperture] }.must_raise Exiftool::NoDefaultResultWithMultiget
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
      _(e.files_with_results.size).must_equal(6)
    end
  end

  def validate_result(result, filename)
    basename = File.basename(filename)
    yaml_file = "test/expected/#{basename}.yaml"
    actual = result.to_hash.delete_if { |k, _v| ignorable_key?(k) }
    File.open(yaml_file, 'w') { |out| YAML.dump(actual, out) } if ENV['DUMP_RESULTS']
    expected = File.open(yaml_file) { |f| YAML.safe_load(f, permitted_classes: [Symbol, Date, Rational]) }
    expected.delete_if { |k, _v| ignorable_key?(k) }
    _(actual).must_equal_hash(expected)
  end

  puts "Ignoring #{IGNORABLE_KEYS.size} keys."

  def ignorable_key?(key)
    IGNORABLE_KEYS.include?(key) || IGNORABLE_PATTERNS.any? { |ea| key.to_s =~ ea }
  end
end
