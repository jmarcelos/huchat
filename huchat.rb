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




# class Perguntas
#   include Elasticsearch::Model
#   include Elasticsearch::Model::Callbacks
#
#   @@pergunta
#   @@resposta
#
#   def search(query)
#     __elasticsearch__.search(
#       {
#         query: {
#           multi_match: {
#             query: query,
#             fields: ['title^10', 'text']
#           }
#         }
#       }
#     )
#   end
#
#   def
#
# end
