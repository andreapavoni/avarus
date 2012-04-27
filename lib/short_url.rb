require 'redis'

class ShortUrl
  Config = Struct.new(:redis, :rkey)

  attr_accessor :url, :id

  def initialize(opts={})
    opts = {url: nil, id: nil}.merge! opts

    @config = self.class.config
    @url = opts[:url]
    @id = opts[:id] || generate_id
  end

  # class methods
  class << self
    def configure
      yield config
    end

    def config
      @config ||= Config.new(Redis.new, 'shorturl')
    end

    def find(id)
      url = @config.redis.get(key_id(id))
      new(url: url, id: id) if url
    end

    def find_by_url(url)
      id = @config.redis.get(key_url(url))
      new(url: url, id: id) if id
    end

    def find_or_create(url)
      find_by_url(url) || create(url)
    end

    def create(url)
      new(url: url).save
    end

    def key_id(id)
      "#{@config.rkey}.id|#{id}"
    end

    def key_url(url)
      "#{@config.rkey}.url|#{url}"
    end

  end # class methods

  def save
    return false unless valid?

    @config.redis.multi do
      @config.redis.set(key_id, @url)
      @config.redis.set(key_url, @id)
    end
    self
  end

  def valid?
    validate_url_format && validate_url_uniqueness
  end

  private

  def key_id
    self.class.key_id(@id)
  end

  def key_url
    self.class.key_url(@url)
  end

  def generate_id
    loop do
      seed = Time.now.to_i + @config.redis.incr("#{@config.rkey}.counter")
      new_id = base62(seed)
      return new_id unless self.class.find(new_id)
    end
  end

  def validate_url_format
    # I took the regex from:
    # http://www.igvita.com/2006/09/07/validating-url-in-ruby-on-rails/
    http_regex = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
    @url.is_a?(String) && !(http_regex.match @url).nil?
  end

  def validate_url_uniqueness
    self.class.find_by_url(@url) ? false : true
  end

  def base62(num)
    # adapted from http://refactormycode.com/codes/125-base-62-encoding
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    return '0' if num == 0
    enc = ''
    while num > 0
      enc << chars[num.modulo(62)]
      num /= 62
    end
    enc.reverse!
  end

end
