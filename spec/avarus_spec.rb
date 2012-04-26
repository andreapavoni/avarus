require_relative 'helper'
require 'avarus'
require 'test/unit'
require 'rack/test'

describe Avarus do
  include Rack::Test::Methods
  let(:app) { Avarus }

  before do
    ShortUrl.config.redis.flushdb
    @short_url = ShortUrl.create('http://example.com')
  end

  # def app
  #   Avarus
  # end

  describe "GET /" do
    it "responds with status 200" do
      get '/'

      last_response.ok?.must_be :==, true
    end
  end

  describe "GET /:id" do
    it "redirects to url" do
      get "/#{@short_url.id}"

      last_response.redirect?.must_be :==, true
      last_response.location.must_equal @short_url.url
    end

    describe "when id is not found" do
      it "responds with 404" do
        get "/notfound"

        last_response.redirect?.must_be :==, false
        last_response.status.must_equal 404
      end
    end
  end

  describe "POST /" do
    describe "with valid url" do
      before do
        post '/', {url: @short_url.url}
        @result = JSON(last_response.body)
      end

      it "responds with JSON format" do
        last_response.content_type.must_equal 'application/json'
      end

      it "returns id and url values" do
        @short_url.id.must_equal @result['id']
        @short_url.url.must_equal @result['url']
      end
    end

    describe "with invalid url" do
      it "responds with error 400" do
        post '/', {url: 'invalidexample.com'}

        last_response.status.must_equal 400
      end
    end
  end

end
