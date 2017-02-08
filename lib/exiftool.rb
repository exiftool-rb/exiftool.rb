require 'json'
require 'shellwords'
require 'exiftool/result'
require 'forwardable'

class Exiftool
  class NoSuchFile < StandardError ; end
  class NotAFile < StandardError ; end
  class ExiftoolNotInstalled < StandardError ; end
  class NoDefaultResultWithMultiget < StandardError ; end

  def self.command=(path_to_exiftool)
    @command = path_to_exiftool
  end

  def self.command
    @command ||= 'exiftool'
  end

  def self.exiftool_installed?
    exiftool_version > 0
  end

  # This is a string, not a float, to handle versions like "9.40" properly.
  def self.exiftool_version
    @exiftool_version ||= `#{command} -ver 2> /dev/null`.chomp
  end

  def self.expand_path(filename)
    raise(NoSuchFile, filename) unless File.exist?(filename)
    raise(NotAFile, filename) unless File.file?(filename)
    File.expand_path(filename)
  end

  extend Forwardable

  def_delegators :first_result, :to_hash, :to_display_hash, :symbol_display_hash, :raw, :[]

  def initialize(filenames, exiftool_opts = '')
    @file2result = {}
    filenames = [filenames] if (filenames.is_a?(String) || filenames.is_a?(Pathname))
    unless filenames.empty?
      escaped_filenames = filenames.map do |f|
        Shellwords.escape(self.class.expand_path(f.to_s))
      end.join(' ')
      # I'd like to use -dateformat, but it doesn't support timezone offsets properly,
      # nor sub-second timestamps.
      cmd = "#{self.class.command} #{exiftool_opts} -j -coordFormat \"%.8f\" #{escaped_filenames} 2> /dev/null"
      json = `#{cmd}`.chomp
      raise ExiftoolNotInstalled if json == ''
      JSON.parse(json).each do |raw|
        result = Result.new(raw)
        @file2result[result.source_file] = result
      end
    end
  end

  def results(include_results_with_errors = false)
    if include_results_with_errors
      @file2result.values
    else
      @file2result.values.select { |ea| !ea.errors? }
    end
  end

  def result_for(filename)
    @file2result[self.class.expand_path(filename)]
  end

  def files_with_results
    results.map { |ea| ea.source_file }
  end

  def errors?
    @file2result.values.any? { |ea| ea.errors? }
  end

  private

  def first_result
    raise(NoDefaultResultWithMultiget, 'use #result_for when multiple filenames are used') if @file2result.size > 1
    @file2result.values.first
  end
end
