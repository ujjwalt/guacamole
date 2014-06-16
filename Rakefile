# -*- encoding : utf-8 -*-
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard/rake/yardoc_task'
require 'inch/rake'
require 'reek/rake/task'

desc 'Run all specs'
task spec: ['spec:unit', 'spec:acceptance']

namespace :spec do
  desc 'Run unit specs'
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = 'spec/unit/**/*_spec.rb'
  end

  desc 'Run acceptance specs – requires running instance of ArangoDB'
  RSpec::Core::RakeTask.new(:acceptance) do |task|
    task.pattern = 'spec/acceptance/**/*_spec.rb'
  end
end

YARD::Rake::YardocTask.new(:doc)

namespace :metrics do
  Inch::Rake::Suggest.new do |t|
    t.args << '--pedantic'
  end

  Reek::Rake::Task.new do |t|
    t.fail_on_error = true
    t.config_files = '.reek.yml'
  end
end

desc 'Start a REPL with guacamole loaded (not the Rails part)'
task :console do
  require 'bundler/setup'

  require 'pry'
  require 'guacamole'
  ARGV.clear
  Pry.start
end

task default: :spec
task ci: ['spec', 'metrics:reek']
