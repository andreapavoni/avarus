require_relative 'helper'
require 'test/unit'

class ShortUrlTest < Test::Unit::TestCase
  def setup
    ShortUrl.config.redis.flushdb
    @short_url = ShortUrl.create 'http://example.com'
  end

  # class methods

  def test_configure
    # here we only change rkey setting to demonstrate
    # that it works
    custom_rkey = 'mytestkey'
    ShortUrl.configure do |config|
      config.rkey = custom_rkey
    end

    redis = ShortUrl.config.redis.client

    assert_not_equal ShortUrl.config.rkey, APP_CONFIG[:redis_key]
    assert_equal ShortUrl.config.rkey, custom_rkey

    # back to default settings
    ShortUrl.configure do |config|
      config.rkey = APP_CONFIG[:redis_key]
    end

    assert_equal ShortUrl.config.rkey, APP_CONFIG[:redis_key]
  end

  def test_initialize_generates_random_id_by_default
    new_url = ShortUrl.new
    assert_not_nil new_url.id
  end

  def test_initialize_accepts_custom_id
    custom_id = 'mytest'
    new_url = ShortUrl.new id: custom_id
    assert_equal new_url.id, custom_id
  end

  def test_find
    result = ShortUrl.find(@short_url.id)
    assert_not_nil result
    assert_equal result.id, @short_url.id
    assert_equal result.url, @short_url.url
  end

  def test_find_by_url
    result = ShortUrl.find_by_url @short_url.url
    assert_not_nil result
    assert_equal result.id, @short_url.id
    assert_equal result.url, @short_url.url
  end

  def test_find_or_create_returns_existent_record
    found = ShortUrl.find_or_create @short_url.url
    assert_not_nil found
    assert_equal found.id, @short_url.id
    assert_equal found.url, @short_url.url
  end

  def test_find_or_create_creates_non_existent_record
    url = 'http://example2.com'
    assert_nil ShortUrl.find_by_url(url)

    created = ShortUrl.find_or_create(url)
    assert_not_nil created

    fetched = ShortUrl.find_by_url url
    assert_equal fetched.id, created.id
    assert_equal fetched.url, created.url
  end

  def test_create
    url = 'http://example2.com'
    assert_nil ShortUrl.find_by_url(url)

    created = ShortUrl.create(url)
    assert_not_nil created

    fetched = ShortUrl.find_by_url url
    assert_equal fetched.id, created.id
    assert_equal fetched.url, created.url
  end

  # instance methods

  def test_save
    url = 'http://example2.com'
    record = ShortUrl.new(url: url)

    assert_nil ShortUrl.find_by_url(record.url)

    record.save
    assert_not_nil ShortUrl.find_by_url(record.url)
  end

  def test_save_fails_if_url_is_invalid
    url = 'example2.com'
    record = ShortUrl.new(url: url)

    assert_nil ShortUrl.find_by_url(record.url)
    assert_equal false, record.valid?
    assert_equal false, record.save
    assert_nil ShortUrl.find_by_url(record.url)
  end

  def test_save_fails_if_url_is_not_unique
    url = @short_url.url
    record = ShortUrl.new(url: url)

    assert_not_nil ShortUrl.find_by_url(record.url)
    assert_equal false, record.valid?
    assert_equal false, record.save
  end

end
