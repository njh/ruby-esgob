# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'esgob/version'

Gem::Specification.new do |spec|
  spec.name          = "esgob"
  spec.version       = Esgob::VERSION
  spec.authors       = ["Nicholas Humfrey"]
  spec.email         = ["njh@aelius.com"]
  spec.summary       = %q{Client library for talking to the Esgob anycast DNS API.}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = 'http://github.com/njh/ruby-esgob'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_dependency "json", "~> 1.8"
  spec.add_dependency 'thor', '~> 0.19.1'

  if Gem.ruby_version > Gem::Version.new('1.9')
    spec.add_development_dependency 'bundler',  '>= 1.5.0'
    spec.add_development_dependency 'rake',     '>= 0.10.0'
    spec.add_development_dependency 'yard',     '>= 0.8.0'
    spec.add_development_dependency 'fakeweb',  '~> 1.3.0'
    spec.add_development_dependency 'mocha',    '~> 1.1.0'
    spec.add_development_dependency 'simplecov'
  elsif Gem.ruby_version > Gem::Version.new('1.8')
    spec.add_development_dependency 'bundler',  '>= 1.1.0'
    spec.add_development_dependency 'rake',     '~> 0.9.0'
    spec.add_development_dependency 'yard',     '~> 0.8.0'
    spec.add_development_dependency 'fakeweb',  '~> 1.3.0'
    spec.add_development_dependency 'minitest', '~> 5.5.0'
    spec.add_development_dependency 'mocha',    '~> 1.1.0'
  else
    raise "#{Gem.ruby_version} is an unsupported version of ruby"
  end
end
