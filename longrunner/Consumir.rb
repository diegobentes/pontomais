#Script para consumir da Fila e chamar a WebAPI para guardar na base de dados.
require './class/RabbitMQ.rb'

require 'rest-client'
require 'json'

rabbitmq = RabbitMQ::init_express(:queue => "abastecimentos")

begin
    puts ' [*] Aguardando por abastecimentos, pressione CTRL+C para encerrar'
    rabbitmq.listen_queue do |body|
        RestClient.post('http://localhost:3000/vendas', {venda: JSON.parse(body)})
        puts " [x] Received #{body}"
    end
    loop do
        sleep(5)
    end
rescue Interrupt => _
    rabbitmq.close_connection
    exit(0)
end