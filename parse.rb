# encoding: UTF-8
require 'multi_json'
require 'net/http'
require 'redis'


def next_line(file)
  while !file.eof? do
    line = file.gets.strip
    if !line.empty?
      return line
    end
  end
end

def parse_content(first_line, file)
  content = [first_line]
  while !file.eof? do
    line = file.gets.strip
    if !line.empty?
      content.push line
    else
      break
    end
  end
  return content
end

def print_poem(poem)
  w = `tput cols`.to_i
  puts "【#{poem[:title]}】".center(w-poem[:title].length-2)
  if poem[:author]
    puts poem[:author].center(w-poem[:author].length)
  end
  puts
  puts poem[:content].map {|l| l.center(w-l.length)}
  puts
end

filename = ARGV[0]

regex = /卷\d*_\d*\s*【(.*)】\ *(\S*)/

redis = Redis.new

data = []
File.open(filename, 'r') do |file|
  while !file.eof? do
    line = file.gets.strip
    matches = line.match(regex)
    if matches
      captures = matches.captures
      poem = {}
      poem[:name] = captures[0]

      l = nil

      # author
      poem[:content] = [{
        :dataType => 'field',
        :name => 'author',
        :value => nil
      }]
      if captures[1].empty?
        l = next_line(file)
        if l.length <= 4
          poem[:content][0][:value] = l
          l = next_line(file)
        end
      else
        poem[:content][0][:value] = captures[1]
        l = next_line(file)
      end

      # poem
      poem[:content].push({
        :dataType => 'text',
        :name => 'poem',
        :value => parse_content(l, file).join("\r")
      })

      poem[:tag] = ["#唐詩"]
      data.push poem
    end
  end
end

File.open('./poems.json', 'w') do |file|
  file.write MultiJson.dump(data, :pretty => true)
end

# save in redis
data.each do |d|
  i = redis.get "poems:next_id"
  redis.set "poems:#{i}:title", d[:name]
  redis.set "poems:#{i}:author", d[:content][0][:value]
  redis.set "poems:#{i}:poem", d[:content][1][:value]
  redis.sadd "poems:ids", i
  redis.incr "poems:next_id"
end
redis.set "poems:count", data.length

#data.each do |d|
  #uri = URI('http://api.cloverite.com:9000/v0/entity')
  #req = Net::HTTP::Post.new(uri)
  #req.body = MultiJson.dump(d)
  #req.content_type = 'application/json'

  #res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    #http.request(req)
  #end
#end
