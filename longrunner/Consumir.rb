#Script para consumir da Fila e chamar a WebAPI para guardar na base de dados.

require 'bunny'
require 'rest-client'
require 'json'

connection = Bunny.new(hostname: '157.245.133.11', password: "admin", user: "admin")
connection.start

channel = connection.create_channel
queue = channel.queue('abastecimentos')

begin
    puts ' [*] Aguardando por abastecimentos, pressione CTRL+C para encerrar'
    #puts "contem #{queue.message_count} mensagens na fila a serem consumidas"
    #channel.prefetch(queue.message_count)

    queue.subscribe(manual_ack: true) do |delivery_info, _properties, body|
        RestClient.post('http://localhost:3000/vendas', {venda: JSON.parse(body)})
        puts " [x] Received #{body}"
        channel.ack(delivery_info.delivery_tag)
    end

    loop do
        sleep(300)
    end

rescue Interrupt => _
    connection.close  
    exit(0)
end