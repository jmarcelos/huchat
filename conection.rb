require 'elasticsearch'
require 'elasticsearch/model'

class Connection

  def initialize(conexao='http://localhost:9200')
    @client = Elasticsearch::Client.new url: conexao
    self.create_conexao
    puts "conexao estabelecida"
  end

  def create_conexao()
    unless client.indices.exists  index: 'huchat'
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
    value = @client.search index: 'huchat', q: "question:#{pergunta}"
    value["hits"]["hits"].first["_source"]
  end

end


#client = Elasticsearch::Client.new url: 'https://joao:joao@aws-us-east-1-portal6.dblayer.com:10183'
#client = Elasticsearch::Client.new url: 'http://localhost:9200'

#curl -XPUT "http://localhost:9200/movies/movie/1" -d'{"title": "The Godfather","director": "Francis Ford Coppola","year": 1972,"genres": ["Crime", "Drama"]}'

#curl -XPUT "http://localhost:9200/huchat/huchat/1" -d'{"question": "Como marcar minha viagem","answer": "vai estudar"}'
# client.create index: 'huchat',
#               type: 'huchat',
#               body: {
#                question: "lalalal",
#                answer: "resposta"
#               }

#client.search index: 'huchat', q: 'question:lalalal'
#client.search index: 'huchat', body: { query: { match: { answer: 'reps' } } }
