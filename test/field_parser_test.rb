require 'test_helper'

describe Exiftool::FieldParser do
  it 'creates snake-case symbolic keys properly' do
    p = Exiftool::FieldParser.new('HyperfocalDistance', '')
    _(p.sym_key).must_equal(:hyperfocal_distance)
  end

  it 'creates display keys properly' do
    p = Exiftool::FieldParser.new('InternalSerialNumber', '')
    _(p.display_key).must_equal('Internal Serial Number')
  end

  it 'parses date flags without warnings' do
    p = Exiftool::FieldParser.new('DateStampMode', 'Off')
    _(p.value).must_equal('Off')
  end

  it 'leaves dates without timezones as strings' do
    p = Exiftool::FieldParser.new('CreateDate', '2004:09:19 12:25:20')
    _(p.value).must_equal('2004:09:19 12:25:20')
  end

  it 'extracts YMD from timestamps' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '2004:09:19 12:25:20')
    _(p.civil_date).must_equal(Date.civil(2004, 9, 19))
  end

  it 'ignores "zero-date" YMD timestamps' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '0000:00:00 00:00:00')
    _(p.civil_date).must_be_nil
  end

  it 'ignores "zero-date" YMD dates' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '0000:00:00')
    _(p.civil_date).must_be_nil
  end

  it 'skips invalid dates' do
    p = Exiftool::FieldParser.new('GPSDateTime', '0111:00:30 20:31:58Z')
    _(p.value).must_equal('0111:00:30 20:31:58Z')
    _(p.civil_date).must_be_nil
  end

  it 'returns nil for YMD for date flags' do
    p = Exiftool::FieldParser.new('DateStampMode', 'Off')
    _(p.civil_date).must_be_nil
  end

  it 'parses sub-second times' do
    p = Exiftool::FieldParser.new('SubSecDateTimeOriginal', '2011:09:25 20:08:09.234-08:00')
    _(p.value).must_equal(Time.parse('2011-09-25 20:08:09.234-08:00'))
  end

  it 'parses dates with timezones' do
    p = Exiftool::FieldParser.new('FileAccessDate', '2013:07:14 10:50:33-07:00')
    _(p.value).must_equal(Time.parse('2013-07-14 10:50:33-07:00'))
  end

  it 'parses date-times with only zeroes' do
    p = Exiftool::FieldParser.new('MediaCreateDate', '0000:00:00 00:00:00')
    _(p.value).must_equal('0000:00:00 00:00:00')
  end

  it 'parses dates with only zeroes' do
    p = Exiftool::FieldParser.new('ModifyDate', '0000:00:00')
    _(p.value).must_equal('0000:00:00')
  end

  it 'parses fractions properly' do
    p = Exiftool::FieldParser.new('ShutterSpeedValue', '1/6135')
    _(p.value).must_equal(Rational(1, 6135))
  end

  it 'parses N GPS coords' do
    p = Exiftool::FieldParser.new('GPSLatitude', '37.50233333 N')
    _(p.value).must_be_close_to(37.50233333)
  end

  it 'parses S GPS coords' do
    p = Exiftool::FieldParser.new('GPSLatitude', '37.50233333 S')
    _(p.value).must_be_close_to(-37.50233333)
  end

  it 'parses E GPS coords' do
    p = Exiftool::FieldParser.new('GPSLongitude', '122.47566667 E')
    _(p.value).must_be_close_to(122.47566667)
  end

  it 'parses W GPS coords' do
    p = Exiftool::FieldParser.new('GPSLongitude', '122.47566667 W')
    _(p.value).must_be_close_to(-122.47566667)
  end

  it 'parses numerical only GPS coordinates' do
    p = Exiftool::FieldParser.new('GPSLongitude', -122.475666666667)
    _(p.value).must_be_close_to(-122.475666666667)
  end
end
