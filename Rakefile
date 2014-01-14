require 'rubygems'
require 'rake/gempackagetask'
require './lib/nugget/version.rb'

spec = Gem::Specification.new do |s|
  s.name = "nugget"
  s.version = Nugget::VERSION
  s.author = "joe williams"
  s.email = "joe@joetify.com"
  s.homepage = "http://github.com/joewilliams/nugget"
  s.platform = Gem::Platform::RUBY
  s.summary = "a http and tcp testing service"
  s.files = FileList["{bin, lib}/**/*"].to_a
  s.require_path = "lib"
  s.bindir = "bin"
  s.executables = %w( nugget )
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
  %w{mixlib-config mixlib-log mixlib-cli turd yajl-ruby thin}.each { |gem| s.add_dependency gem }
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
