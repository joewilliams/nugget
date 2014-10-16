lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nugget/version'
require 'rake'

spec = Gem::Specification.new do |s|
  s.name = "nugget"
  s.version = Nugget::VERSION
  s.author = "joe williams"
  s.email = "joe@joetify.com"
  s.homepage = "http://github.com/joewilliams/nugget"
  s.platform = Gem::Platform::RUBY
  s.summary = "a http and tcp testing service"
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.bindir = "bin"
  s.executables = %w( nugget check_nugget )
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
  %w{mixlib-config mixlib-log mixlib-cli turd yajl-ruby thin statsd-ruby}.each { |gem| s.add_dependency gem }
  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rake"
end
