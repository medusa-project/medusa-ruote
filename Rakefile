require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'rcov/rcovtask'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:spec_rcov) do |t|
  t.rcov = true
end
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = '--format pretty --color'
end