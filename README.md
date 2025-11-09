# Ruby wrapper for ExifTool

[![Build Status](https://github.com/exiftool-rb/exiftool.rb/actions/workflows/build.yml/badge.svg)](https://github.com/exiftool-rb/exiftool.rb/actions)
[![Gem Version](https://badge.fury.io/rb/exiftool.svg)](http://rubygems.org/gems/exiftool)
[![Gem Downloads](https://img.shields.io/gem/dt/exiftool.svg)](http://rubygems.org/gems/exiftool)
[![Gem Latest](https://img.shields.io/gem/dtv/exiftool.svg)](http://rubygems.org/gems/exiftool)
[![Code Coverage](https://qlty.sh/gh/exiftool-rb/projects/exiftool.rb/coverage.svg)](https://qlty.sh/gh/exiftool-rb/projects/exiftool.rb)
[![Maintainability](https://qlty.sh/gh/exiftool-rb/projects/exiftool.rb/maintainability.svg)](https://qlty.sh/gh/exiftool-rb/projects/exiftool.rb)

This gem is the simplest thing that could possibly work that
reads the output of [exiftool](http://www.sno.phy.queensu.ca/~phil/exiftool)
and renders it into a ruby hash, with _correctly typed values_ and symbolized keys.

Ruby 3.1 through 3.3 are supported.

## Ruby Support Deprecation Notice

Future releases of `exiftool` Gem will no longer support following
Ruby Versions due to their [End Of Life](https://www.ruby-lang.org/en/downloads/branches/) announcements:

- Ruby 2.4 (EOL 2020-03-31)
- Ruby 2.5 (EOL 2021-03-31)
- Ruby 2.6 (EOL 2022-04-12)
- Ruby 2.7 (EOL 2023-03-31)
- Ruby 3.0 (EOL 2024-04-23)

The latest Exiftool is recommended, but you'll get that automatically by using the
[exiftool_vendored](https://github.com/exiftool-rb/exiftool_vendored.rb) gem!

## Features

- Multiget support
- GPS latitude and longitude values are parsed as signed floats,
  where north and east are positive, and west and south are negative.
- Values like shutter speed and exposure time are rendered as Rationals,
  which lets the caller show them as fractions (1/250) or as comparable numeric instances.
- String values like "interop" and "serial number" are kept as strings
  (which preserves zero prefixes)
- Timestamps are attempted to be interpreted with correct timezones and sub-second resolution, if
  the header contains that data.
  If the timestamp doesn't include a timezone offset, we leave it as a string, rather than inferring
  the current system timezone which might not be applicable to the image. We add a decimal yyyymmdd
  key for these problematic fields.
- No `method_missing` madness
- Excellent test coverage
- Clean, readable code
- MIT license

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

This can be dramatically more efficient than spinning up the `exiftool`
process for each file due to the cost of spinning up perl.

Supply an array to the Exiftool initializer, then use `.result_for`:

```ruby
require 'exiftool'
e = Exiftool.new(Dir["**/*.jpg"])
result = e.result_for("path/to/iPhone 4S.jpg")
result.to_hash
# => {:make => "Apple", :gps_longitude => -122.47566667, …
result[:gps_longitude]
# => -122.47566667
```

Or iterate through files_with_results:

```ruby
e.files_with_results
# => ["path/to/iPhone 4S.jpg", "path/to/Droid X.jpg", …
```

### Reading from IO

You can pass an IO object to read metadata from standard input. ExifTool will infer the file type from content:

```ruby
io = File.open('test/IMG_2452.jpg', 'rb')
e = Exiftool.new(io)
e[:make] # => "Canon"
```

### Dates without timezones

It seems that most exif dates don't include timezone offsets, without which forces us to assume the
current timezone is applicable to the image, which isn't necessarily correct.

To be correct, we punt and return the exiftool-formatted string, which will be something like
`%Y:%m:%d %H:%M:%S`.

If the clock was set correctly on your camera, the date will be the correct calendar day
as far as you were concerned when you took the photo. Given that, we
add a `_civil` key associated to just the calendar date of the field, which should be safe-ish.

```ruby
require 'exiftool'
e = Exiftool.new("test/IMG_2452.jpg")
e[:date_time_original]
=> "2011:07:06 09:46:45"
e[:date_time_original_civil]
=> #<Date: 2011-07-06 ((2455749j,0s,0n),+0s,2299161j)>
```

### When things go wrong

- `Exiftool::NoSuchFile` is raised if the provided filename doesn't exist.
- `Exiftool::ExiftoolNotInstalled` is raised if `exiftool` isn't in your `PATH`.
- If ExifTool has a problem reading EXIF data, no exception is raised, but `#errors?` will return true:

```ruby
Exiftool.new("Gemfile").errors?
#=> true
```

## Installation

### Step 1: Install ExifTool

The easiest way is to use the "vendored" exiftool in the
[exiftool_vendored](https://github.com/exiftool-rb/exiftool_vendored.rb) gem. Just add

    gem 'exiftool_vendored'

to your Gemfile, run `bundle`, and you're done. (Note that it depends on the `exiftool` gem,
so really, you're done! Skip step 2!)

If you want to install exiftool on your system yourself:

- MacOS with [homebrew](http://mxcl.github.io/homebrew/)? `brew install exiftool`
- Debian or Ubuntu? `sudo apt-get install libimage-exiftool-perl`
- Something else? [RTFM](http://www.sno.phy.queensu.ca/~phil/exiftool/install.html)!

### Step 2: Add the gem

If you didn't use `exiftool_vendored`, then add this your Gemfile:

    gem 'exiftool'

and then run `bundle`.

If you have exiftool installed outside of ruby's `PATH`, add an initializer that points the gem
to the tool, like this: `Exiftool.command = '/home/ruby/Image-ExifTool-9.33/exiftool'`. You don't need to do
this if you've installed added the exiftool directory to the PATH of the shell that runs ruby.

## Change history

### 1.2.7

- Fixed [exiftool-rb/exiftool_vendored.rb#37](https://github.com/exiftool-rb/exiftool_vendored.rb/issues/37) issue where track tags were treated as fractions and were reduced to the lowest term in the output.
- Switched from codeclimate to qlty

### 1.2.5 - 1.2.6

- Maintenance release

### 1.2.4

- Moved from travis-ci.org to travis-ci.com
- Updated Ruby versions for Travis CI runs. Running on 2.6.8, 2.7.4 and 3.0.2
- Updated simplecov version for test coverage reporting
- Merged [PR #23](https://github.com/exiftool-rb/exiftool.rb/pull/23) by [urtabajev](https://github.com/urtabajev) that fixes `NameError` related to `pathname` standard library when multiget is used

### 1.2.3

- Added Ruby 3.0.0 to Travis CI tests and updated config to Ruby 2.7.2
- Added Ruby Deprecation note to README.md about dropping support for Ruby 2.4 and 2.5 starting March 31, 2021
- rubocop fixes
- Added `rubocop-minitest` and `rubocop-rake` for better styleguide coverage

### 1.2.2

- Code is following rubocop style guide (mostly)
- Improved tests and code coverage

### 1.2.1

- Fixed `exiftool_installed?`, referenced by [issue #11](https://github.com/exiftool-rb/exiftool.rb/issues/11).

### 1.2.0

- Add check for valid civil date. Addresses [issue
  #10](https://github.com/exiftool-rb/exiftool.rb/issues/10)). Thanks for the
  assist, [Victor Bogado da Silva Lins](https://github.com/bogado)!

### 1.1.0

- Support `Pathname` instances as constructor args.
  Addresses [issue #8](https://github.com/exiftool-rb/exiftool.rb/issues/8)

- Dropped official support for jruby due to CI failures.

### 1.0.1

- Updates from [Sergey Morozov](https://github.com/morozgrafix) to address [issue #7](https://github.com/exiftool-rb/exiftool.rb/issues/7),
  which allows for `-n` (force numeric values)

### 0.8.0

- Updates from [Sergey Morozov](https://github.com/morozgrafix) to support newer
  rubies, and validate UTF field parsing was handled correctly

### 0.7.0

- Added zero-date parsing to address [issue #2](https://github.com/exiftool-rb/exiftool.rb/issues/2).
  Thanks for the pull request, [Sergey Morozov](https://github.com/morozgrafix)!
- Updated Travis configuration (RIP 1.9.x).

### 0.5.0

- Introduced YMD parsing for all date columns, even if they don't specify timezone offsets.

### 0.4.0

- Added `#raw_hash` to `Exiftool::Result` to support columns that can have parsing issues,
  like dates that don't include timezone offsets.

### 0.3.1

- `.exiftool_version` is now a string rather than a float,
  which didn't work so well with version numbers like "9.40"

### 0.3.0

- Support for explicitly setting the path to exiftool with
  `Exiftool.command`
- Removed the test directory from the gem contents, as it included the test
  images and made the gem ginormous.

### 0.2.0

- Renamed from exiftoolr to exiftool

### 0.1.0

- Better timestamp parsing—now both sub-second and timezone offsets are handled
  correctly
- Switched to minitest-spec
- Ruby 1.8.7 is no longer supported, hence the minor version uptick.

### 0.0.9

- Explicitly added MIT licensing to the gemspec.

### 0.0.8

- Extracted methods in parsing to make the code complexity lower. FOUR DOT OH GPA

### 0.0.7

- Added warning values for EXIF headers that are corrupt
- Made initialize gracefully accept an empty array, or an array of Pathname
  instances
- Added support for ruby 1.9.3 and exiftool v8.15 (Ubuntu Natty) and v8.85
  (current stable version)

### 0.0.5

Fixed homepage URL in gemspec

### 0.0.4

Added support for multiple file fetching (which is _much_ faster for large directories)
