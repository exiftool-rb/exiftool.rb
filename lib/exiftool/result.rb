require 'exiftool/field_parser'

class Exiftool
  class Result
    attr_reader :raw, :to_hash, :to_display_hash, :sym2display, :display2sym

    def initialize(raw_hash)
      @raw = {}
      @to_hash = {}
      @to_display_hash = {}
      @sym2display = {}
      raw_hash.each do |key, raw_value|
        p = FieldParser.new(key, raw_value)
        @raw[p.sym_key] = raw_value
        @to_hash[p.sym_key] = p.value
        @to_display_hash[p.display_key] = p.value
        @sym2display[p.sym_key] = p.display_key

        civil_date = p.civil_date
        if civil_date
          civil_date_key = "#{p.sym_key}_civil".to_sym
          @to_hash[civil_date_key] = civil_date
        end
      end
      @display2sym = @sym2display.invert
    end

    def [](key)
      @to_hash[key]
    end

    def source_file
      self[:source_file]
    end

    def errors?
      self[:error] == 'Unknown file type' || self[:warning] == 'Unsupported file type'
    end
  end
end
