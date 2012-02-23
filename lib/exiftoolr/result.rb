require 'time'
require 'rational'

class Exiftoolr
  class Result
    attr_reader :to_hash, :to_display_hash, :symbol_display_hash

    WORD_BOUNDARY_RES = [/([A-Z\d]+)([A-Z][a-z])/, /([a-z\d])([A-Z])/]
    FRACTION_RE = /\d+\/\d+/

    def initialize(raw_hash)
      @raw_hash = raw_hash
      @to_hash = { }
      @to_display_hash = { }
      @symbol_display_hash = { }

      @raw_hash.each do |k, v|
        display_key = WORD_BOUNDARY_RES.inject(k) { |key, regex| key.gsub(regex, '\1 \2') }
        sym_key = display_key.downcase.gsub(' ', '_').to_sym
        if sym_key == :gps_latitude || sym_key == :gps_longitude
          value, direction = v.split(" ")
          v = value.to_f
          v *= -1 if direction == 'S' || direction == 'W'
        elsif display_key =~ /\bdate\b/i
          v = Time.parse(v)
        elsif v =~ FRACTION_RE
          v = Rational(*v.split('/').collect { |ea| ea.to_i })
        end
        @to_hash[sym_key] = v
        @to_display_hash[display_key] = v
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
