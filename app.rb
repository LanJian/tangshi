require 'multi_json'
require 'sinatra'
require 'redis'

configure do
  set :redis, Redis.new
end

get '/poem' do
  redis = settings.redis
  i = redis.srandmember("poems:ids").to_i
  title = redis.get "poems:#{i}:title"
  author = redis.get "poems:#{i}:author"
  poem = redis.get "poems:#{i}:poem"
  return MultiJson.dump({:title => title, :author => author, :poem => poem})
end
