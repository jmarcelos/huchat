require 'sinatra'


get '/busca/:busca' do

  resp = params[:busca]
  "{'resposta':{'question':'#{resp}', 'answer':'oi oi oi'}}"

end
