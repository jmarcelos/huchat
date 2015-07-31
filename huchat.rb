require 'sinatra'
require_relative "conection"

conexao = Connection.new "https://joao:joao@aws-us-east-1-portal6.dblayer.com:10183"

get '/busca/:busca' do

  resp = params[:busca]
  conexao.search(resp)
end

post '/insert' do
  @pergunta = params[:pergunta]
  @resposta = params[:resposta]
  puts "pergunta: #{@pergunta} - resposta #{@resposta}"
  conexao.insere(@pergunta, @resposta)
end

post '/exibicao' do
  conexao.insere_exibicao
  status 200
  body "Perguntas inseridas com sucesso"
end

delete 'destruir' do
  conexao.destroy
  status 200
  body "Indice destruido com sucesso  "
end
