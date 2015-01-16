# encoding: UTF-8
require 'httpclient'
require 'multi_json'

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

client = HTTPClient.new
res = client.get('http://localhost:4567/poem')
poem = MultiJson.load(res.body, :symbolize_keys => true)
print_poem(poem[:title], poem[:author], poem[:content])
