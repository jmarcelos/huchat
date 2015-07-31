require 'sinatra'
require 'json'
require 'redis'

get '/' do
  erb :index, layout: :bootstrap
end

get '/admin' do
  erb :admin, layout: :bootstrap
end

post '/busca' do
  content_type :json

  resp = params[:busca]
  { resposta: { question: resp, answer: 'oi oi oi'}}.to_json
end

get "/info" do
  redis = Redis.new(:url => "redis://x:ADOTFQVEAZDEYDVU@aws-us-east-1-portal.6.dblayer.com:10185/")
  ch = redis.pubsub 'channels'
end