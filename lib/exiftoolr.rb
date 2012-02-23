require "exiftoolr/version"
require "exiftoolr/result"

require 'json'
require 'shellwords'

class Exiftoolr
  class NoSuchFile < StandardError; end
  class ExiftoolNotInstalled < StandardError; end

  def self.exiftool_installed?
    `exiftool -ver 2> /dev/null`.to_f > 0
  end

  def initialize(filenames, exiftool_opts = "")
    escaped_filenames = filenames.to_a.collect do |f|
      raise NoSuchFile, f unless File.exist?(f)
      Shellwords.escape(f)
    end.join(" ")
    json = `exiftool #{exiftool_opts} -j −coordFormat "%.8f" -dateFormat "%Y-%m-%d %H:%M:%S" #{escaped_filenames} 2> /dev/null`
    raise ExiftoolNotInstalled if json == ""
    @file2result = {}
    JSON.parse(json).each{|raw| @file2result[raw["SourceFile"]] = Result.new(raw)}
  end

  def result_for(filename)
    @file2result[filename]
  end

  def files_with_results
    @file2result.keys
  end

  def to_hash
    first.to_hash
  end

  def to_display_hash
    first.to_display_hash
  end

  def symbol_display_hash
    first.symbol_display_hash
  end

  def errors?
    @file2result.values.any?{|ea|ea.errors?}
  end

  private

  def first
    raise InvalidArgument, "use #result_for when multiple filenames are used" if @file2result.size > 1
    @file2result.values.first
  end
end
