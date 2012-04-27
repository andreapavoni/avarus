require_relative 'helper'

describe ShortUrl do
  before do
    ShortUrl.config.redis.flushdb
    @short_url = ShortUrl.create 'http://example.com'
  end

  describe "validations" do
    describe "url" do
      it "has correct format" do
        url = 'notvalid.com'
        record = ShortUrl.new(url: url)

        record.valid?.must_be :==, false
      end

      it "is unique" do
        url = @short_url.url
        record = ShortUrl.new(url: url)

        # record.must_be :valid?, false
        record.valid?.must_be :==, false
      end
    end

  end

  describe "class methods" do
    describe ".configure" do
      it "sets configuration keys" do
        custom_rkey = 'mytestkey'

        ShortUrl.configure do |config|
          config.rkey = custom_rkey
        end

        ShortUrl.config.rkey.wont_equal APP_CONFIG[:redis_key]

        ShortUrl.config.rkey.must_equal custom_rkey

        # back to default settings
        ShortUrl.configure do |config|
          config.rkey = APP_CONFIG[:redis_key]
        end

        ShortUrl.config.rkey.must_equal APP_CONFIG[:redis_key]
      end
    end

    describe ".initialize" do
      it "generates random id by default" do
        ShortUrl.new.id.wont_be_nil
      end

      it "accepts a custom id" do
        custom_id = 'mytest'
        new_url = ShortUrl.new id: custom_id
        new_url.id.must_equal custom_id
      end
    end

    describe ".find" do
      it "returns a ShortUrl instance" do
        result = ShortUrl.find(@short_url.id)
        result.wont_be_nil
        result.id.must_equal @short_url.id
        result.url.must_equal @short_url.url
      end

      describe "when not found" do
        it "returns nil" do
          ShortUrl.find('noexists').must_be_nil
        end
      end
    end

    describe ".find_by_url" do
      it "returns a ShortUrl instance" do
        result = ShortUrl.find_by_url @short_url.url

        result.wont_be_nil
        result.id.must_equal @short_url.id
        result.url.must_equal @short_url.url
      end

      describe "when not found" do
        it "returns nil" do
          ShortUrl.find_by_url('http://notfound.com').must_be_nil
        end
      end
    end

    describe ".find_or_create" do
      describe "when record already exists" do
        it "returns existent record" do
          found = ShortUrl.find_or_create @short_url.url

          found.wont_be_nil
          found.id.must_equal @short_url.id
          found.url.must_equal @short_url.url
        end
      end

      describe "when record doesn't exist" do
        it "returns a new record" do
          url = 'http://example2.com'
          ShortUrl.find_by_url(url).must_be_nil

          created = ShortUrl.find_or_create(url)
          created.wont_be_nil

          fetched = ShortUrl.find_by_url url
          fetched.id.must_equal created.id
          fetched.url.must_equal created.url
        end
      end
    end

    describe ".create" do
      it "creates a new record" do
        url = 'http://example2.com'
        ShortUrl.find_by_url(url).must_be_nil

        created = ShortUrl.create(url)
        created.wont_be_nil

        fetched = ShortUrl.find_by_url url
        fetched.id.must_equal created.id
        fetched.url.must_equal created.url
      end
    end

  end # class methods

  describe "instance methods" do
    describe "#save" do
      before do
        url = 'http://example2.com'
        @record = ShortUrl.new(url: url)
        ShortUrl.find_by_url(@record.url).must_be_nil
      end

      it "stores object on db" do
        @record.save
        ShortUrl.find_by_url(@record.url).wont_be_nil
      end

      it "returns an instance" do
        @record.save.must_be_instance_of(ShortUrl)
      end

      describe "with invalid data" do
        it "returns false" do
          @record.url = 'notvalid'
          @record.save.must_be :==, false
        end
      end
    end

  end
end
