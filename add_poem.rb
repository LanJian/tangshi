# encoding: UTF-8
require 'redis'

filename = ARGV[0]
lines = File.readlines(filename)
title = lines[0].strip
author = lines[1].strip
poem = lines[2..-1].map(&:strip).join("\r")

redis = Redis.new
i = redis.get "poems:next_id"
redis.set "poems:#{i}:title", title
redis.set "poems:#{i}:author", author
redis.set "poems:#{i}:poem", poem
redis.sadd "poems:ids", i
redis.incr "poems:next_id"

puts i
