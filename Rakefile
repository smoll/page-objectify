require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

require 'cucumber/rake/task'

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = ""
  t.cucumber_opts << "--format pretty"
end

Cucumber::Rake::Task.new(:cucumber_wip, "Run @wip Cucumber features, fail if any pass") do |t|
  t.cucumber_opts = "-p wip"
end

# Manually verify CHANGELOG.md before pushing
task :changelog do
  sh "github_changelog_generator smoll/page-objectify"
end

task :auto_changelog do
  sh "github_changelog_generator smoll/page-objectify"
  sh "git add CHANGELOG.md"
  sh "git commit -m 'Update CHANGELOG.md at #{Time.now}'"
  sh "git push origin master"
end

desc "[Automatically] release v#{Gem::Specification::load("page-objectify.gemspec").version} and push its changelog"
task autopilot: [:release, :auto_changelog]

task test: [:spec, :cucumber]
task default: :test
