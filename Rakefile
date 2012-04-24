require 'bundler'

APP_ENV = (ENV['RACK_ENV'] || 'test').to_sym

# load required gems
Bundler.setup :default, APP_ENV
Bundler.require :default, APP_ENV

require "cutest"

task :test do
  Cutest.run(Dir["test/*_test.rb"])
end

task :default => :test
