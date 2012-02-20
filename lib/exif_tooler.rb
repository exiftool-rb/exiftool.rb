require "exif_tooler/version"

require 'json'
require 'shellwords'
require 'time'
require 'rational'

class ExifTooler
  class NoSuchFile < StandardError
  end
  class ExifToolNotInstalled < StandardError
  end

  def initialize(filename, exiftool_opts = "")
    raise NoSuchFile, filename unless File.exist?(filename)
    json = `exiftool #{exiftool_opts} -j −coordFormat "%.8f" -dateFormat "%Y-%m-%d %H:%M:%S" #{Shellwords.escape(filename)} 2> /dev/null`
    raise ExifToolNotInstalled if json == ""
    @raw = JSON.parse(json).first
    convert_exiftool_hash
  end

  def errors?
    @raw.has_key? "Error"
  end

  def to_hash
    @sym_hash
  end

  def to_display_hash
    @display_hash
  end

  def symbol_display_hash
    @symbol_display_hash
  end

  private

  WB1 = /([A-Z\d]+)([A-Z][a-z])/
  WB2 = /([a-z\d])([A-Z])/

  def convert_exiftool_hash
    @sym_hash = { }
    @display_hash = { }
    @symbol_display_hash = { }

    @raw.each do |k, v|
      display_key = k.gsub(WB1, '\1 \2').gsub(WB2, '\1 \2')
      sym_key = display_key.downcase.gsub(' ', '_').to_sym
      if sym_key == :gps_latitude || sym_key == :gps_longitude
        value, direction = v.split(" ")
        v = value.to_f
        v *= -1 if direction == 'S' || direction == 'W'
      elsif display_key =~ /\bdate\b/i
        v = Time.parse(v)
      elsif v =~ /\d+\/\d+/
        v = Rational(*v.split('/').collect { |ea| ea.to_i })
      end
      @display_hash[display_key] = v
      @sym_hash[sym_key] = v
      @symbol_display_hash[sym_key] = display_key
    end
  end
end
