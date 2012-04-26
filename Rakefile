require 'bundler'
require 'rake/testtask'

APP_ENV = 'test'

Bundler.setup :default, APP_ENV
Bundler.require :default, APP_ENV

Rake::TestTask.new do |t|
  t.test_files = Dir["spec/*_spec.rb"]
  # uncomment to get more output
  # t.verbose = true
end

task :default => :test
