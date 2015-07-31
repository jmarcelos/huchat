require 'sinatra'
require 'json'
require 'redis'
#require_relative 'conf'
require_relative 'conection'

conexao = Connection.new("https://joao:joao@aws-us-east-1-portal6.dblayer.com:10183")

get '/' do
  erb :index, layout: :bootstrap
end

get '/admin' do
  erb :admin, layout: :bootstrap
end

get '/busca/:busca' do
  content_type :json

  resp = params[:busca]
  conexao.search(resp)
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

post '/exibicao' do
  conexao.insere_exibicao
  status 200
  body "Perguntas inseridas com sucesso"
end

delete '/destruir' do
  conexao.destroy
  status 200
  body "Indice destruido com sucesso  "
end

post '/create' do
  conexao.create_conexao
  status 200
  body "Indice criado com sucesso  "
end
