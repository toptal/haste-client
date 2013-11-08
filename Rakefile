require File.dirname(__FILE__) + '/lib/haste/version'

task :build do
  system "gem build haste.gemspec"
end

task :release => :build do
  # tag and push
  system "git tag v#{Haste::VERSION}"
  system "git push origin --tags"
  # push the gem
  system "gem push haste-#{Haste::VERSION}.gem"
end
