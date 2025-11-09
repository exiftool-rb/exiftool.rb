# frozen_string_literal: true

require 'json'
require 'shellwords'
require 'open3'
require 'exiftool/result'
require 'forwardable'
require 'pathname'

# Exiftool Class
class Exiftool
  class NoSuchFile < StandardError; end

  class NotAFile < StandardError; end

  class ExiftoolNotInstalled < StandardError; end

  class NoDefaultResultWithMultiget < StandardError; end

  class << self
    attr_writer :command
  end

  def self.command
    @command ||= 'exiftool'
  end

  def self.exiftool_installed?
    exiftool_version.to_f.positive?
  end

  # This is a string, not a float, to handle versions like "9.40" properly.
  def self.exiftool_version
    return @exiftool_version if defined?(@exiftool_version) && @exiftool_version

    stdout_str = ''
    begin
      Open3.popen3(command, '-ver') do |_stdin, stdout, _stderr, wait_thr|
        stdout_str = stdout.read.to_s.chomp
        # Ensure the process is reaped
        wait_thr.value
      end
    rescue Errno::ENOENT
      stdout_str = ''
    end

    @exiftool_version = stdout_str
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
    io_input = nil
    if filenames.is_a?(IO)
      io_input = filenames
      filenames = ['-']
    end

    filenames = [filenames] if filenames.is_a?(String) || filenames.is_a?(Pathname)
    return if filenames.empty?

    expanded_filenames = filenames.map do |f|
      f == '-' ? '-' : self.class.expand_path(f.to_s)
    end
    args = [
      self.class.command,
      *Shellwords.split(exiftool_opts),
      '-j',
      '-coordFormat', '%.8f',
      *expanded_filenames
    ]

    json = ''
    begin
      Open3.popen3(*args) do |stdin, stdout, _stderr, wait_thr|
        if io_input
          # Reading first 64KB.
          # It is enough to parse exif tags.
          # https://en.wikipedia.org/wiki/Exif#Technical_2
          while (chunk = io_input.read(1 << 16))
            stdin.write(chunk)
          end
          stdin.close
        end
        json = stdout.read.to_s.chomp
        wait_thr.value
      end
    rescue Errno::ENOENT
      json = ''
    end

    raise ExiftoolNotInstalled if json == ''

    JSON.parse(json).each do |raw|
      result = Result.new(raw)
      @file2result[result.source_file] = result
    end
  end

  def results(include_results_with_errors: false)
    if include_results_with_errors
      @file2result.values
    else
      @file2result.values.reject(&:errors?)
    end
  end

  def result_for(filename)
    @file2result[self.class.expand_path(filename)]
  end

  def files_with_results
    results.map(&:source_file)
  end

  def errors?
    @file2result.values.any?(&:errors?)
  end

  private

  def first_result
    raise(NoDefaultResultWithMultiget, 'use #result_for when multiple filenames are used') if @file2result.size > 1

    @file2result.values.first
  end
end
