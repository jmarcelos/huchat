require 'sinatra'
require 'json'
require 'redis'
require_relative 'conf'
require_relative 'conection'

conexao = Connection.new(ELASTICSEARCH_ENDPOINT)

get '/' do
  erb :index, layout: :bootstrap
end

get '/admin' do
  erb :admin, layout: :bootstrap
end     

post '/busca' do
  content_type :json

  resp = params[:busca]
  conexao.search(resp)
  # { resposta: { question: resp, answer: 'oi oi oi'}}.to_json
end

get "/info" do
  redis = Redis.new(url: REDIS_ENDOINT)
  redis.pubsub 'channels', 'chat_*'
end

get '/add' do
  erb :add_question, layout: :bootstrap
end

post '/insert' do
  @pergunta = params[:pergunta]
  @resposta = params[:resposta]
  puts "pergunta: #{@pergunta} - resposta #{@resposta}"
  conexao.insere(@pergunta, @resposta)

  "cadastrado com sucesso"
end