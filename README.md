# AVARUS: a minimalistic URL shortener built with code parsimony in mind

An URL shortener's main goal should be about saving charatcters for some
reason (es: microblogging platforms). But what about saving code, ram
and libraries? Avarus tries to answer this question with a minimum set of
tools:

* [Cuba](http://cuba.is): a micro web framework
* redis: both the [gem](https://github.com/redis/redis-rb) and [server](http://redis.io)

## Getting started

### Requirements

* ruby 1.9.x (tested on 1.9.3p125)
* [redis](http://redis.io): I've used the v2.4.9

### Install and run

* start redis server
* download with `git clone <this repo>`
* install required gems: `cd <avarus_dir> && bundle install`
* (optional) run tests: `bundle exec rake`
* `rackup` or just launch any other Rack-compliant ruby webserver

## Todo

* click counter
* basic authentication
* stats

## Contributions & Bugs

* *the easy way:* go to [issues](issues/) page and blame me.
* *the hard way:* repeat the above points, then share your love and send a pull request.

## License
Copyright (c) 2012 Andrea Pavoni http://andreapavoni.com. See LICENSE for details
