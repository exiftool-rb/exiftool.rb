# Ruby wrapper for ExifTool

[![Build Status](https://secure.travis-ci.org/mceachen/exiftoolr.png?branch=master)](http://travis-ci.org/mceachen/exiftoolr)
[![Gem Version](https://badge.fury.io/rb/exiftoolr.png)](http://rubygems.org/gems/exiftoolr)
[![Code Climate](https://codeclimate.com/github/mceachen/exiftoolr.png)](https://codeclimate.com/github/mceachen/exiftoolr)

This gem is the simplest thing that could possibly work that
reads the output of [exiftool](http://www.sno.phy.queensu.ca/~phil/exiftool)
and renders it into a ruby hash, with correctly typed values and symbolized keys.

## What constitutes "correct values"?

* GPS latitude and longitude are rendered as signed floats,
  where north and east are positive, and west and south are negative.
* Values like shutter speed and exposure time are rendered as Rationals,
  which lets the caller show them as fractions (1/250) or as comparable numeric instances.
* String values like "interop" and "serial number" are kept as strings
  (which preserves zero prefixes)
* Timestamps are attempted to be interpreted with correct timezones and sub-second resolution, if
  the header contains that data.
  Please note that EXIF headers don't always include a timezone offset, so we just adopt the system
  timezone, which may, of course, be wrong.

## Usage

```ruby
require 'exiftoolr'
e = Exiftoolr.new("path/to/iPhone 4S.jpg")
e.to_hash
# => {:make => "Apple", :gps_longitude => -122.47566667, …
e.to_display_hash
# => {"Make" => "Apple", "GPS Longitude" => -122.47566667, …
```

### Multiple file support

This gem supports Exiftool's multiget, which lets you fetch metadata for many files at once.

This can be dramatically more efficient (like, 60x faster) than spinning up the ```exiftool```
process for each file.

Supply an array to the Exiftoolr initializer, then use ```.result_for```:

```ruby
require 'exiftoolr'
e = Exiftoolr.new(Dir["**/*.jpg"])
result = e.result_for("path/to/iPhone 4S.jpg")
result.to_hash
# => {:make => "Apple", :gps_longitude => -122.47566667, …
result[:gps_longitude]
# => -122.47566667

e.files_with_results
# => ["path/to/iPhone 4S.jpg", "path/to/Droid X.jpg", …
```

### When things go wrong

* ```Exiftoolr::NoSuchFile``` is raised if the provided filename doesn't exist.
* ```Exiftoolr::ExiftoolNotInstalled``` is raised if ```exiftool``` isn't in your ```PATH```.
* If ExifTool has a problem reading EXIF data, no exception is raised, but ```#errors?``` will return true:

```ruby
Exiftoolr.new("Gemfile").errors?
#=> true
```


## Installation

First [install ExifTool](http://www.sno.phy.queensu.ca/~phil/exiftool/install.html).

Then, add this your Gemfile:

    gem 'exiftoolr'

and then run ```bundle```.

## Change history

### 0.0.10

* Better timestamp parsing—now both sub-second and timezone offsets are handled correctly
* Switched to minitest-spec

### 0.0.9

* Explicitly added MIT licensing to the gemspec.

### 0.0.8

* Extracted methods in parsing to make the code complexity lower. FOUR DOT OH GPA

### 0.0.7

* Added warning values for EXIF headers that are corrupt
* Made initialize gracefully accept an empty array, or an array of Pathname instances
* Added support for ruby 1.9.3 and exiftool v8.15 (Ubuntu Natty) and v8.85 (current stable version)

### 0.0.5

Fixed homepage URL in gemspec

### 0.0.4

Added support for multiple file fetching (which is *much* faster for large directories)
