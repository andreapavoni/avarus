require_relative 'helper'
require 'avarus'
require 'test/unit'
require 'rack/test'

class AvarusTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    ShortUrl.config.redis.flushdb
    @short_url = ShortUrl.create('http://example.com')
  end

  def app
    Avarus
  end

  def test_get_homepage
    get '/'
    assert last_response.ok?
  end

  def test_get_id_redirects_to_url
    get "/#{@short_url.id}"
    assert last_response.redirect?
    assert_equal @short_url.url, last_response.location
  end

  def test_get_id_returns_404_when_url_not_found
    get "/notfound"
    assert !last_response.redirect?
    assert_equal 404, last_response.status
  end

  def test_post_returns_shortened_url_in_json_format
    post '/', {url: @short_url.url}
    result = JSON(last_response.body)

    assert_equal 'application/json', last_response.content_type
    assert_equal @short_url.id, result['id']
    assert_equal @short_url.url, result['url']
  end

  def test_post_returns_error_with_invalid_url
    post '/', {url: 'invalidexample.com'}

    assert_equal 400, last_response.status
  end
end
