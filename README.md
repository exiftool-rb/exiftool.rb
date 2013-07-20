# Ruby wrapper for ExifTool

[![Build Status](https://secure.travis-ci.org/mceachen/exiftool.png?branch=master)](http://travis-ci.org/mceachen/exiftool)
[![Gem Version](https://badge.fury.io/rb/exiftool.png)](http://rubygems.org/gems/exiftool)
[![Code Climate](https://codeclimate.com/github/mceachen/exiftool.png)](https://codeclimate.com/github/mceachen/exiftool)

This gem is the simplest thing that could possibly work that
reads the output of [exiftool](http://www.sno.phy.queensu.ca/~phil/exiftool)
and renders it into a ruby hash, with correctly typed values and symbolized keys.

Rubies 1.9 and later are supported.

## Features

* Multiget support
* GPS latitude and longitude values are parsed as signed floats,
  where north and east are positive, and west and south are negative.
* Values like shutter speed and exposure time are rendered as Rationals,
  which lets the caller show them as fractions (1/250) or as comparable numeric instances.
* String values like "interop" and "serial number" are kept as strings
  (which preserves zero prefixes)
* Timestamps are attempted to be interpreted with correct timezones and sub-second resolution, if
  the header contains that data.
  Please note that EXIF headers don't always include a timezone offset, so we just adopt the system
  timezone, which may, of course, be wrong.
* No ```method_missing``` madness
* Excellent test coverage
* Clean, readable code
* MIT license

## Usage

```ruby
require 'exiftool'
e = Exiftool.new("path/to/iPhone 4S.jpg")
e.to_hash
# => {:make => "Apple", :gps_longitude => -122.47566667, …
e.to_display_hash
# => {"Make" => "Apple", "GPS Longitude" => -122.47566667, …
```

### Multiget support

This gem supports Exiftool's multiget, which lets you fetch metadata for many files at once.

This can be dramatically more efficient (like, 60x faster) than spinning up the ```exiftool```
process for each file.

Supply an array to the Exiftool initializer, then use ```.result_for```:

```ruby
require 'exiftool'
e = Exiftool.new(Dir["**/*.jpg"])
result = e.result_for("path/to/iPhone 4S.jpg")
result.to_hash
# => {:make => "Apple", :gps_longitude => -122.47566667, …
result[:gps_longitude]
# => -122.47566667

e.files_with_results
# => ["path/to/iPhone 4S.jpg", "path/to/Droid X.jpg", …
```

### When things go wrong

* ```Exiftool::NoSuchFile``` is raised if the provided filename doesn't exist.
* ```Exiftool::ExiftoolNotInstalled``` is raised if ```exiftool``` isn't in your ```PATH```.
* If ExifTool has a problem reading EXIF data, no exception is raised, but ```#errors?``` will return true:

```ruby
Exiftool.new("Gemfile").errors?
#=> true
```

## Installation

### Step 1: Install ExifTool

The easiest way is to use the "vendored" exiftool in the
[exiftool_vendored](https://github.com/mceachen/exiftool_vendored) gem. Just add

    gem 'exiftool_vendored'

to your Gemfile, run ```bundle```, and you're done. (Note that it depends on the ```exiftool``` gem,
so really, you're done! Skip step 2!)

If you want to install exiftool on your system yourself:

* MacOS with [homebrew](http://mxcl.github.io/homebrew/)? ```brew install exiftool```
* Debian or Ubuntu? ```sudo apt-get install libimage-exiftool-perl```
* Something else? [RTFM](http://www.sno.phy.queensu.ca/~phil/exiftool/install.html)!

### Step 2: Add the gem

If you didn't use ```exiftool_vendored```, then add this your Gemfile:

    gem 'exiftool'

and then run ```bundle```.

If you have exiftool installed outside of ruby's ```PATH```, add an initializer that points the gem
to the tool, like this: ```Exiftool.command = '/home/ruby/Image-ExifTool-9.33/exiftool'```. You don't need to do
this if you've installed added the exiftool directory to the PATH of the shell that runs ruby.

## Change history

### 0.3.0

* Support for explicitly setting the path to exiftool with ```Exiftool.command```
* Removed the test directory from the gem contents, as it included the test images and made the gem
  ginormous.

### 0.2.0

* Renamed from exiftoolr to exiftool

### 0.1.0

* Better timestamp parsing—now both sub-second and timezone offsets are handled correctly
* Switched to minitest-spec
* Ruby 1.8.7 is no longer supported, hence the minor version uptick.

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
