require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rake/extensiontask'

Rake::ExtensionTask.new('sidetiq_ext')

Rake::TestTask.new do |t|
  t.pattern = 'test/**/test_*.rb'
end

task default: :test
