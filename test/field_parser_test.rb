require 'test_helper'

describe Exiftool::FieldParser do
  it 'creates snake-case symbolic keys properly' do
    p = Exiftool::FieldParser.new('HyperfocalDistance', '')
    p.sym_key.must_equal(:hyperfocal_distance)
  end

  it 'creates display keys properly' do
    p = Exiftool::FieldParser.new('InternalSerialNumber', '')
    p.display_key.must_equal('Internal Serial Number')
  end

  it 'parses date flags without warnings' do
    p = Exiftool::FieldParser.new('DateStampMode', 'Off')
    p.value.must_equal('Off')
  end

  it 'leaves dates without timezones as strings' do
    p = Exiftool::FieldParser.new('CreateDate', '2004:09:19 12:25:20')
    p.value.must_equal('2004:09:19 12:25:20')
  end

  it 'extracts YMD from timestamps' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '2004:09:19 12:25:20')
    p.civil_date.must_equal(Date.civil(2004, 9, 19))
  end

  it 'ignores "zero-date" YMD timestamps' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '0000:00:00 00:00:00')
    p.civil_date.must_be_nil
  end

  it 'ignores "zero-date" YMD dates' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '0000:00:00')
    p.civil_date.must_be_nil
  end

  it 'returns nil for YMD for date flags' do
    p = Exiftool::FieldParser.new('DateStampMode', 'Off')
    p.civil_date.must_be_nil
  end

  it 'parses sub-second times' do
    p = Exiftool::FieldParser.new('SubSecDateTimeOriginal', '2011:09:25 20:08:09.234-08:00')
    p.value.must_equal(Time.parse('2011-09-25 20:08:09.234-08:00'))
  end

  it 'parses dates with timezones' do
    p = Exiftool::FieldParser.new('FileAccessDate', '2013:07:14 10:50:33-07:00')
    p.value.must_equal(Time.parse('2013-07-14 10:50:33-07:00'))
  end

  it 'parses date-times with only zeroes' do
    p = Exiftool::FieldParser.new('MediaCreateDate', '0000:00:00 00:00:00')
    p.value.must_equal('0000:00:00 00:00:00')
  end

  it 'parses dates with only zeroes' do
    p = Exiftool::FieldParser.new('ModifyDate', '0000:00:00')
    p.value.must_equal('0000:00:00')
  end

  it 'parses fractions properly' do
    p = Exiftool::FieldParser.new('ShutterSpeedValue', '1/6135')
    p.value.must_equal(Rational(1, 6135))
  end

  it 'parses N GPS coords' do
    p = Exiftool::FieldParser.new('GPSLatitude', '37.50233333 N')
    p.value.must_be_close_to(37.50233333)
  end

  it 'parses S GPS coords' do
    p = Exiftool::FieldParser.new('GPSLatitude', '37.50233333 S')
    p.value.must_be_close_to(-37.50233333)
  end

  it 'parses E GPS coords' do
    p = Exiftool::FieldParser.new('GPSLongitude', '122.47566667 E')
    p.value.must_be_close_to(122.47566667)
  end

  it 'parses W GPS coords' do
    p = Exiftool::FieldParser.new('GPSLongitude', '122.47566667 W')
    p.value.must_be_close_to(-122.47566667)
  end
end
