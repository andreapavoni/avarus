require 'bundler'

APP_ENV = (ENV['RACK_ENV'] || 'development')

Bundler.setup(:default, APP_ENV)
Bundler.require(:default, APP_ENV)

require 'erb'
path = File.read(File.expand_path("app_config.yml", File.dirname(__FILE__)))
APP_CONFIG = YAML.load(ERB.new(path).result)[APP_ENV]

$:.unshift File.expand_path("../", File.dirname(__FILE__))
require 'lib/short_url'

ShortUrl.configure do |config|
  config.redis = Redis.new APP_CONFIG['redis']
  config.rkey = 'avarus'
end
