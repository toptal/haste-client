require 'rspec/core/rake_task'
require File.dirname(__FILE__) + '/lib/haste/version'

RSpec::Core::RakeTask.new(:spec)

task :build => :spec do
  system "gem build haste.gemspec"
end

task :release => :build do
  # tag and push
  system "git tag v#{Haste::VERSION}"
  system "git push origin --tags"
  # push the gem
  system "gem push haste-#{Haste::VERSION}.gem"
end
