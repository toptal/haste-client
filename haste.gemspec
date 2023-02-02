require 'rubygems'
require File.dirname(__FILE__) + '/lib/haste/version'

Gem::Specification.new do |s|
  s.name = 'haste'
  s.author = 'Toptal'
  s.add_development_dependency('rspec')
  s.add_dependency('json')
  s.add_dependency('faraday', '~> 0.9')
  s.description = 'CLI Haste Client'
  s.license = 'MIT License'
  s.homepage = 'https://github.com/toptal/haste-client'
  s.email = 'open-source@toptal.com'
  s.executables = 'haste'
  s.files = Dir['lib/**/*.rb', 'haste']
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'Haste Client'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = Haste::VERSION
end
