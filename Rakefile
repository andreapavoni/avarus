require 'bundler'
require 'rake/testtask'

APP_ENV = (ENV['RACK_ENV'] || 'test').to_sym

Bundler.setup :default, APP_ENV
Bundler.require :default, APP_ENV

Rake::TestTask.new do |t|
  t.test_files = Dir["test/*_test.rb"]
  # uncomment to get more output
  # t.verbose = true
end

task :default => :test
