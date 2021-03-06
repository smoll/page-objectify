# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'page-objectify/version'

Gem::Specification.new do |spec|
  spec.name          = "page-objectify"
  spec.version       = PageObjectify::VERSION
  spec.authors       = ["Shujon Mollah"]
  spec.email         = ["mollah@gmail.com"]

  spec.summary       = %q{A Ruby page class generator (for use with the page-object gem)}
  spec.homepage      = "https://github.com/smoll/page-objectify"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri", "~> 1.6"
  spec.add_dependency "unparser", "~> 0.2.4"
  spec.add_dependency "page-object", "~> 1.1"

  spec.add_development_dependency "aruba", "~> 0.10.0"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "byebug", "~> 8"
  spec.add_development_dependency "chromedriver-helper", "~> 1.0"
  spec.add_development_dependency "github_changelog_generator", "~> 1.9"
  spec.add_development_dependency "phantomjs", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "watir-webdriver", "~> 0.9.1"
end
