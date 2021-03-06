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
                              question:  { type: 'string' },
                              answer:  { type: 'string'},

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
    @client.search index:'huchat', body: { query: { match: { answer: '#{pergunta}' } }}
    value = @client.search index: 'huchat', q: "question:#{pergunta}"
    trata_resposta(value)
  end

  def trata_resposta(value)
    total_respostas = value["hits"]["total"]

    if total_respostas == 1
      resposta = value["hits"]["hits"].first["_source"]
      json = { response: resposta, redirecionar_chat: false }.to_json
      puts "Encontrei #{total_respostas}"
    elsif total_respostas < 1
      puts "Encontrei #{total_respostas}"
      resposta = {question: '', answer: "Desculpa, mas não sei responder sua pergunta, vou perguntar para outro atendente aqui. 1 minuto"}
      json = { response: resposta, redirecionar_chat: true }
    else total_respostas > 1

      puts "Encontrei #{total_respostas}"
      resposta = {question: "", answer: "Poderia ser mais específico por favor, não entendi sua pergunta"}
      respostas = value["hits"]["hits"]
      respostas.each do |valor|
        puts "Pergunta: #{valor["_source"]["question"]} com score #{valor["_score"]}"
      end

      score = respostas.first['_score']
      puts "Score do primeiro match é de #{score}"
      if score != nil && score >= 0.5
        puts 'Achei uma resposta que está acima de 80%'
        resposta = respostas.first['_source']
      end

      json = { response: resposta, redirecionar_chat: false }
    end

    json.to_json
  end

  def insere_exibicao
    @client.create index: 'huchat',
                  type: 'huchat',
                  body: {
                   question: "Como faço para verificar a disponibilidade de data no pacote?",
                   answer: "Entre em contato com o Hugo!!!"
                  }
    @client.create index: 'huchat',
                  type: 'huchat',
                  body: {
                   question: "Comprei um pacote! Como faço minha reserva?",
                   answer: "Veja o email de confirmação, está lá a resposta`"
                  }
    @client.create index: 'huchat',
                  type: 'huchat',
                  body: {
                   question: "Como faço para verificar o andamento das minhas solicitações?",
                   answer: "Na área do cliente é possível ver o andamento das solicitoes"
                  }
    @client.create index: 'huchat',
                  type: 'huchat',
                  body: {
                   question: "Desejo cancelar a minha compra, como faço?",
                   answer: "Vamos liberar os creditos na área do cliente"
                  }
    @client.create index: 'huchat',
                  type: 'huchat',
                  body: {
                   question: "Como faço para usar meus créditos?",
                   answer: "Entre no site e torra essa grana"
                  }
    @client.create index: 'huchat',
                  type: 'huchat',
                  body: {
                   question: "Como faço para comprar créditos?",
                   answer: "Atualmente não vendemos creditos, mas no futuro quem sabe"
                  }
    puts 'Exibição criada com sucesso'
  end

  def destroy
    puts 'destruindo indice'
    @client.indices.delete index: 'huchat', id: 1
  end

end


#client.search index:'huchat', body: { query: { match: { answer: 'Desejo cancelar a minha compra, como faço?' } }}

#client = Elasticsearch::Client.new url: 'https://joao:joao@aws-us-east-1-portal6.dblayer.com:10183'
#client = Elasticsearch::Client.new url: 'http://localhost:9200'

#curl -XPUT "http://localhost:9200/huchat/huchat/1" -d'{"question": "Como marcar minha viagem","answer": "vai estudar"}'
#
# client.indices.delete index: 'huchat', id: 1

#client.search index: 'huchat', q: 'question:lalalal'
#client.search index: 'huchat', body: { query: { match: { answer: 'pacote' } } }
#client.search index: 'huchat', body: { query: { match: { answer: 'quero usar créditos na viagem' } } }
