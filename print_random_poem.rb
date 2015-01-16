# encoding: UTF-8
require 'multi_json'
require 'redis'

def put_border(str)
  if str[0] == ' '
    str[0] = ':'
  end
  if str[str.length-1] == ' '
    str[str.length-1] = ':'
  end
  return str
end

def print_poem(title, author, poem)
  w = `tput cols`.to_i
  puts "".center(w, ':')
  puts put_border("".center(w, ' '))

  # title
  str = "【#{title}】".center(w-title.length-2+title.count('·'))
  puts put_border(str)

  if author
    str = author.center(w-author.length)
    puts put_border(str)
  end
  puts put_border("".center(w, ' '))
  p = poem.split("\r")
  content = p.map {|l| l.center(w-l.length)}
  puts content.map {|l| put_border(l)}
  puts put_border("".center(w, ' '))
  puts "".center(w, ':')
end


#filename = ARGV[0]
#data = MultiJson.load(File.read(filename), :symbolize_keys => true)

redis = Redis.new
i = redis.srandmember("poems:ids").to_i
title = redis.get "poems:#{i}:title"
author = redis.get "poems:#{i}:author"
poem = redis.get "poems:#{i}:poem"
print_poem(title, author, poem)
