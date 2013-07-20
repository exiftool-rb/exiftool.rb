require 'json'
require 'shellwords'
require 'exiftool/result'

class Exiftool
  class NoSuchFile < StandardError ; end
  class NotAFile < StandardError ; end
  class ExiftoolNotInstalled < StandardError ; end

  def self.command=(path_to_exiftool)
    @@command = path_to_exiftool
  end

  def self.command
    @@command || 'exiftool'
  end

  def self.exiftool_installed?
    exiftool_version > 0
  end

  def self.exiftool_version
    @@exiftool_version ||= `#{command} -ver 2> /dev/null`.to_f
  end

  def self.expand_path(filename)
    raise(NoSuchFile, filename) unless File.exist?(filename)
    raise(NotAFile, filename) unless File.file?(filename)
    File.expand_path(filename)
  end

  def initialize(filenames, exiftool_opts = '')
    @file2result = {}
    filenames = [filenames] if filenames.is_a?(String)
    unless filenames.empty?
      escaped_filenames = filenames.collect do |f|
        Shellwords.escape(self.class.expand_path(f.to_s))
      end.join(" ")
      # I'd like to use -dateformat, but it doesn't support timezone offsets properly,
      # nor sub-second timestamps.
      cmd = "#{self.class.command} #{exiftool_opts} -j -coordFormat \"%.8f\" #{escaped_filenames} 2> /dev/null"
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
    raise InvalidArgument, 'use #result_for when multiple filenames are used' if @file2result.size > 1
    @file2result.values.first
  end
end
