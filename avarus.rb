$:.unshift File.dirname(__FILE__)

require 'config/init'

require 'cuba'
require 'json'

class Avarus < Cuba; end

Avarus.define do
  on get do
    on root do
      res.write File.read('views/index.html')
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
          res.write JSON.pretty_generate({
            id: "#{APP_CONFIG[:app_url]}/#{link.id}",
            url: link.url}
          )
        else
          res.status = 400
        end
      end
    end
  end
end

