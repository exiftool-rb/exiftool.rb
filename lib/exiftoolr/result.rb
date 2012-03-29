require 'time'
require 'rational'

class Exiftoolr
  class Result
    attr_reader :to_hash, :to_display_hash, :symbol_display_hash

    WORD_BOUNDARY_RES = [/([A-Z\d]+)([A-Z][a-z])/, /([a-z\d])([A-Z])/]
    FRACTION_RE = /^(\d+)\/(\d+)$/

    def initialize(raw_hash)
      @raw_hash = raw_hash
      @to_hash = { }
      @to_display_hash = { }
      @symbol_display_hash = { }

      @raw_hash.each do |k, raw_v|
        display_key = WORD_BOUNDARY_RES.inject(k) { |key, regex| key.gsub(regex, '\1 \2') }
        sym_key = display_key.downcase.gsub(' ', '_').to_sym
        begin
          if sym_key == :gps_latitude || sym_key == :gps_longitude
            value, direction = raw_v.split(" ")
            v = value.to_f
            v *= -1 if direction == 'S' || direction == 'W'
          elsif raw_v.is_a?(String)
            if display_key =~ /\bdate\b/i
              v = Time.parse(raw_v)
            else
              scan = raw_v.scan(FRACTION_RE).first
              unless scan.nil?
                v = Rational(*scan.collect { |ea| ea.to_i })
              end
            end
          end
        rescue StandardError => e
          v = "Warning: Parsing '#{raw_v}' for attribute '#{k}' raised #{e.message}"
        end
        @to_hash[sym_key] = v || raw_v
        @to_display_hash[display_key] = v || raw_v
        @symbol_display_hash[sym_key] = display_key
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
end
