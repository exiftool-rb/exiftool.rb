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
      @raw_hash.each do |key, raw_value|
        p = Parser.new(key, raw_value)
        @to_hash[p.sym_key] = p.value
        @to_display_hash[p.display_key] = p.value
        @symbol_display_hash[p.sym_key] = p.display_key
      end
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
  end

  class Parser
    WORD_BOUNDARY_RES = [/([A-Z\d]+)([A-Z][a-z])/, /([a-z\d])([A-Z])/]
    FRACTION_RE = /^(\d+)\/(\d+)$/

    attr_reader :display_key, :sym_key, :raw_value

    def initialize(key, raw_value)
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
      v = "Warning: Parsing '#{raw_value}' for attribute '#{k}' raised #{e.message}"
    end

    private

    def for_lat_long
      if sym_key == :gps_latitude || sym_key == :gps_longitude
        value, direction = raw_value.split(" ")
        value.to_f * (['S', 'W'].include?(direction) ? -1 : 1)
      end
    end

    def for_date
      if raw_value.is_a?(String) && display_key =~ /\bdate\b/i
        Time.parse(raw_value)
      end
    end

    def for_fraction
      if raw_value.is_a?(String)
        scan = raw_value.scan(FRACTION_RE).first
        v = Rational(*scan.collect { |ea| ea.to_i }) unless scan.nil?
      end
    end
  end
end
