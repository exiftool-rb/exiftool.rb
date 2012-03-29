# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "exiftoolr/version"

Gem::Specification.new do |s|
  s.name        = "exiftoolr"
  s.version     = Exiftoolr::VERSION
  s.authors     = ["Matthew McEachen"]
  s.email       = ["matthew-github@mceachen.org"]
  s.homepage    = "https://github.com/mceachen/exiftoolr"
  s.summary     = %q{Multiget ExifTool wrapper for ruby}
  s.description = %q{Multiget ExifTool wrapper for ruby}

  s.rubyforge_project = "exiftoolr"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.requirements << "ExifTool (see http://www.sno.phy.queensu.ca/~phil/exiftool/)"

  s.add_dependency "json"
  s.add_development_dependency "rake"
end
