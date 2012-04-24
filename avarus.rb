$:.unshift File.dirname(__FILE__)

require 'config/init'

require 'cuba'
require 'json'

class Avarus < Cuba; end

Avarus.define do
  on get do
    on root do
      res.write 'Hello World'
    end

    on ":id" do |id|
      if short = ShortUrl.find(id)
        res.redirect short.url
      else
        res.status = 404
      end
    end
  end

  on post do
    on root do
      on param('url') do |url|
        if link = ShortUrl.find_or_create(url.to_s)
          res["Content-Type"] = "application/json"
          res.write JSON.pretty_generate({id: link.id, url: link.url})
        else
          res.status = 400
        end
      end
      on true do
        res.status = 400
      end
    end
  end
end

