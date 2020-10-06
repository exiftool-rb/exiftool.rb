# frozen_string_literal: true

require 'time'

class Exiftool
  # Exiftool FiledParser Class
  class FieldParser
    WORD_BOUNDARY_RES = [/([A-Z\d]+)([A-Z][a-z])/, /([a-z\d])([A-Z])/].freeze
    FRACTION_RE = %r{^(\d+)/(\d+)$}.freeze
    YMD_RE = /\A(\d{4}):(\d{2}):(\d{2})\b/.freeze
    ZERO_DATE_RE = /\A[+:0 ]+\z/.freeze

    attr_reader :key, :display_key, :sym_key, :raw_value

    def initialize(key, raw_value)
      @key = key
      @display_key = WORD_BOUNDARY_RES.inject(key) { |k, regex| k.gsub(regex, '\1 \2') }
      @sym_key = display_key.downcase.gsub(' ', '_').to_sym
      @raw_value = raw_value
    end

    def value
      @value ||= if lat_long?
                   as_lat_long
                 elsif date?
                   as_date
                 elsif fraction?
                   as_fraction
                 else
                   raw_value
                 end
    rescue StandardError => e
      # :nocov:
      "Warning: Parsing '#{raw_value}' for attribute '#{key}' raised #{e.message}"
      # :nocov:
    end

    def civil_date
      return unless date? && !zero_date?

      ymd = raw_value.scan(YMD_RE).first
      return unless ymd

      ymd_a = ymd.map(&:to_i)
      Date.civil(*ymd_a) if Date.valid_civil?(*ymd_a)
    end

    private

    def lat_long?
      sym_key == :gps_latitude || sym_key == :gps_longitude
    end

    def as_lat_long
      return raw_value if raw_value.is_a?(Numeric)

      value, direction = raw_value.split(' ')
      return unless value =~ /\A\d+\.?\d*\z/

      value.to_f * (%w[S W].include?(direction) ? -1 : 1)
    end

    def date?
      raw_value.is_a?(String) && display_key =~ /\bdate\b/i
    end

    def zero_date?
      raw_value =~ ZERO_DATE_RE
    end

    def as_date
      try_parse { Time.strptime(raw_value, '%Y:%m:%d %H:%M:%S%z') } ||
        try_parse { Time.strptime(raw_value, '%Y:%m:%d %H:%M:%S.%L%z') } ||
        raw_value
    end

    def try_parse
      yield
    rescue ArgumentError
      nil
    end

    def fraction?
      raw_value.is_a?(String) && raw_value =~ FRACTION_RE
    end

    def as_fraction
      scan = raw_value.scan(FRACTION_RE).first
      Rational(*scan.map(&:to_i)) unless scan.nil?
    end
  end
end
