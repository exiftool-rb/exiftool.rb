require 'time'
require 'rational'

class Exiftool
  class FieldParser

    WORD_BOUNDARY_RES = [/([A-Z\d]+)([A-Z][a-z])/, /([a-z\d])([A-Z])/]
    FRACTION_RE = /^(\d+)\/(\d+)$/

    attr_reader :key, :display_key, :sym_key, :raw_value

    def initialize(key, raw_value)
      @key = key
      @display_key = WORD_BOUNDARY_RES.inject(key) { |k, regex| k.gsub(regex, '\1 \2') }
      @sym_key = display_key.downcase.gsub(' ', '_').to_sym
      @raw_value = raw_value
    end

    def value
      for_lat_long ||
        for_date ||
        for_fraction ||
        raw_value
    rescue StandardError => e
      "Warning: Parsing '#{raw_value}' for attribute '#{key}' raised #{e.message}"
    end

    YMD_RE = /\A(\d{4}):(\d{2}):(\d{2})\b/

    def civil_date
      if datish?
        ymd = raw_value.scan(YMD_RE).first
        Date.civil(*ymd.map{|ea|ea.to_i}) if ymd
      end
    end

    private

    def for_lat_long
      if sym_key == :gps_latitude || sym_key == :gps_longitude
        value, direction = raw_value.split(" ")
        if value =~ /\A\d+\.?\d*\z/
          value.to_f * (['S', 'W'].include?(direction) ? -1 : 1)
        end
      end
    end

    def datish?
      raw_value.is_a?(String) && !(raw_value =~ /\A(\d{4}):((\d{2}):(0{2})|(0{2}):(\d{2}))\b/) && display_key =~ /\bdate\b/i
    end

    def for_date
      if datish?
        try_parse { Time.strptime(raw_value, '%Y:%m:%d %H:%M:%S%z') } ||
          try_parse { Time.strptime(raw_value, '%Y:%m:%d %H:%M:%S.%L%z') }
      end
    end

    def try_parse
      yield
    rescue ArgumentError
      nil
    end

    def for_fraction
      if raw_value.is_a?(String)
        scan = raw_value.scan(FRACTION_RE).first
        v = Rational(*scan.map { |ea| ea.to_i }) unless scan.nil?
      end
    end
  end
end
