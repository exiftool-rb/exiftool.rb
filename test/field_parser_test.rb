# frozen_string_literal: true

require 'test_helper'

describe Exiftool::FieldParser do
  it 'creates snake-case symbolic keys properly' do
    p = Exiftool::FieldParser.new('HyperfocalDistance', '')

    assert_equal(:hyperfocal_distance, p.sym_key)
  end

  it 'creates display keys properly' do
    p = Exiftool::FieldParser.new('InternalSerialNumber', '')

    assert_equal('Internal Serial Number', p.display_key)
  end

  it 'parses date flags without warnings' do
    p = Exiftool::FieldParser.new('DateStampMode', 'Off')

    assert_equal('Off', p.value)
  end

  it 'leaves dates without timezones as strings' do
    p = Exiftool::FieldParser.new('CreateDate', '2004:09:19 12:25:20')

    assert_equal('2004:09:19 12:25:20', p.value)
  end

  it 'extracts YMD from timestamps' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '2004:09:19 12:25:20')

    assert_equal(Date.civil(2004, 9, 19), p.civil_date)
  end

  it 'ignores "zero-date" YMD timestamps' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '0000:00:00 00:00:00')

    assert_nil(p.civil_date)
  end

  it 'ignores "zero-date" YMD dates' do
    p = Exiftool::FieldParser.new('DateTimeOriginal', '0000:00:00')

    assert_nil(p.civil_date)
  end

  it 'skips invalid dates' do
    p = Exiftool::FieldParser.new('GPSDateTime', '0111:00:30 20:31:58Z')

    assert_equal('0111:00:30 20:31:58Z', p.value)
    assert_nil(p.civil_date)
  end

  it 'returns nil for YMD for date flags' do
    p = Exiftool::FieldParser.new('DateStampMode', 'Off')

    assert_nil(p.civil_date)
  end

  it 'parses sub-second times' do
    p = Exiftool::FieldParser.new('SubSecDateTimeOriginal', '2011:09:25 20:08:09.234-08:00')

    assert_equal(Time.parse('2011-09-25 20:08:09.234-08:00'), p.value)
  end

  it 'parses dates with timezones' do
    p = Exiftool::FieldParser.new('FileAccessDate', '2013:07:14 10:50:33-07:00')

    assert_equal(Time.parse('2013-07-14 10:50:33-07:00'), p.value)
  end

  it 'parses date-times with only zeroes' do
    p = Exiftool::FieldParser.new('MediaCreateDate', '0000:00:00 00:00:00')

    assert_equal('0000:00:00 00:00:00', p.value)
  end

  it 'parses dates with only zeroes' do
    p = Exiftool::FieldParser.new('ModifyDate', '0000:00:00')

    assert_equal('0000:00:00', p.value)
  end

  it 'parses fractions properly' do
    p = Exiftool::FieldParser.new('ShutterSpeedValue', '1/6135')

    assert_equal(Rational(1, 6135), p.value)
  end

  it 'parses N GPS coords' do
    p = Exiftool::FieldParser.new('GPSLatitude', '37.50233333 N')

    assert_in_delta(37.50233333, p.value)
  end

  it 'parses S GPS coords' do
    p = Exiftool::FieldParser.new('GPSLatitude', '37.50233333 S')

    assert_in_delta(-37.50233333, p.value)
  end

  it 'parses E GPS coords' do
    p = Exiftool::FieldParser.new('GPSLongitude', '122.47566667 E')

    assert_in_delta(122.47566667, p.value)
  end

  it 'parses W GPS coords' do
    p = Exiftool::FieldParser.new('GPSLongitude', '122.47566667 W')

    assert_in_delta(-122.47566667, p.value)
  end

  it 'parses numerical only GPS coordinates' do
    p = Exiftool::FieldParser.new('GPSLongitude', -122.475666666667)

    assert_in_delta(-122.475666666667, p.value)
  end

  it 'parses track tags without reducing a fraction to lowest terms' do
    p = Exiftool::FieldParser.new('Track', '2/24')

    assert_equal('2/24', p.value)
  end
end
