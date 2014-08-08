require 'sinatra'
class Server < Sinatra::Base
  get '/' do
    "hello word"
  end
end
