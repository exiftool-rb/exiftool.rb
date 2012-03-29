require "exiftoolr/version"
require "exiftoolr/result"

require 'json'
require 'shellwords'

class Exiftoolr
  class NoSuchFile < StandardError ; end
  class NotAFile < StandardError ; end
  class ExiftoolNotInstalled < StandardError ; end

  def self.exiftool_installed?
    exiftool_version > 0
  end

  def self.exiftool_version
    @@exiftool_version ||= `exiftool -ver 2> /dev/null`.to_f
  end

  def self.expand_path(filename)
    raise NoSuchFile, filename unless File.exist?(filename)
    raise NotAFile, filename unless File.file?(filename)
    File.expand_path(filename)
  end

  def initialize(filenames, exiftool_opts = "")
    @file2result = {}
    unless filenames.empty?
      escaped_filenames = filenames.collect do |f|
        Shellwords.escape(self.class.expand_path(f.to_s))
      end.join(" ")
      cmd = "exiftool #{exiftool_opts} -j −coordFormat \"%.8f\" -dateFormat \"%Y-%m-%d %H:%M:%S\" #{escaped_filenames} 2> /dev/null"
      json = `#{cmd}`
      raise ExiftoolNotInstalled if json == ""
      JSON.parse(json).each do |raw|
        result = Result.new(raw)
        @file2result[result.source_file] = result
      end
    end
  end

  def result_for(filename)
    @file2result[self.class.expand_path(filename)]
  end

  def files_with_results
    @file2result.values.collect { |r| r.source_file unless r.errors? }.compact
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
    @file2result.values.any? { |ea| ea.errors? }
  end

  private

  def first
    raise InvalidArgument, "use #result_for when multiple filenames are used" if @file2result.size > 1
    @file2result.values.first
  end
end
