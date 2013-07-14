require 'exiftoolr/parser'

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
      self[:error] == 'Unknown file type' || self[:warning] == 'Unsupported file type'
    end
  end
end
