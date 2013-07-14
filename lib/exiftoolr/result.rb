require 'time'
require 'rational'

class Exiftoolr
  class Result
    attr_reader :to_hash, :to_display_hash, :symbol_display_hash

    def initialize(raw_hash)
      @raw_hash = raw_hash
      @to_hash = {}
      @to_display_hash = {}
      @symbol_display_hash = {}
      consume_raw_hash
    end

    def [](key)
      @to_hash[key]
    end

    def source_file
      self[:source_file]
    end

    def errors?
      self[:error] == "Unknown file type" || self[:warning] == "Unsupported file type"
    end

    private

    WORD_BOUNDARY_RES = [/([A-Z\d]+)([A-Z][a-z])/, /([a-z\d])([A-Z])/]
    FRACTION_RE = /^(\d+)\/(\d+)$/

    def value_for_lat_long(raw_value)
      value, direction = raw_value.split(" ")
      value.to_f * (['S', 'W'].include?(direction) ? -1 : 1)
    end

    def consume_raw_hash
      @raw_hash.each do |k, raw_value|
        display_key = WORD_BOUNDARY_RES.inject(k) { |key, regex| key.gsub(regex, '\1 \2') }
        sym_key = display_key.downcase.gsub(' ', '_').to_sym
        begin
          if sym_key == :gps_latitude || sym_key == :gps_longitude
            value = value_for_lat_long(raw_value)
          elsif raw_value.is_a?(String)
            if display_key =~ /\bdate\b/i
              v = Time.parse(raw_value)
            else
              scan = raw_value.scan(FRACTION_RE).first
              v = Rational(*scan.collect { |ea| ea.to_i }) unless scan.nil?
            end
          end
        rescue StandardError => e
          v = "Warning: Parsing '#{raw_value}' for attribute '#{k}' raised #{e.message}"
        end
        @to_hash[sym_key] = v || raw_value
        @to_display_hash[display_key] = v || raw_value
        @symbol_display_hash[sym_key] = display_key
      end
    end

  end
end
