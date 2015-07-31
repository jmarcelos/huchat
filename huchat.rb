require 'sinatra'
#require 'conection.rb'
require 'elasticsearch'
require 'elasticsearch/model'

class Connection


  def initialize(conexao='http://localhost:9200')
    @client = Elasticsearch::Client.new url: conexao
    self.create_conexao
    puts "conexao estabelecida"
  end

  def create_conexao
    unless @client.indices.exists  index: 'huchat'
      puts "criando indice"
      @client.indices.create index: 'huchat', type: 'huchat',
                body: {
                  mappings: {
                    document: {
                      properties: {
                              question:  { type: 'string', analyzer: 'keyword' },
                              answer:  { type: 'string', analyzer: 'keyword' },

                      }
                    }
                  }
                }
      end
  end

  def insere(pergunta, resposta)

    @client.create index: 'huchat',
                  type: 'huchat',
                  body: {
                   question: pergunta,
                   answer: resposta
                  }
    puts "inserido com sucesso"

  end

  def search(pergunta)
    puts "buscando #{pergunta}"
    value = @client.search index: 'huchat', q: "question:#{pergunta}"
    json = { response: value["hits"]["hits"].first["_source"] }.to_json
  end

end

conexao = Connection.new

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
