#script que simula as bombas transmitindo os dados para uma fila
#passara um carro a cada 50 segundos para abastecer pela bomba
#uma media de 72 carros por hora em cada bomba

#impotando classe de Abastecimento
require './class/Abastecimento.rb'

#Importando a biblioteca de conexao com o RabbitMQ
require 'bunny'

#criando a conexao com o servidor de fila
connection = Bunny.new(hostname: '157.245.133.11', password: "admin", user: "admin")
#abrindo a conexao com o servidor de fila
connection.start
#criando um canal
channel = connection.create_channel
#criando uma fila
queue = channel.queue('abastecimentos')

#array que recebera as threads
threads = []

begin
    puts ' [*] Abastecendo... Pressione CTRL+C para encerrar'
    #gerando threads de acordo com a quantidade de bombas informadas (para uma execucao paralela ao codigo do requisito)
    #(ARGV[0].to_i..ARGV[1].to_i).each do |numero_bomba| 
        #thr = Thread.new do
            loop do
                #gerando um novo abastecimento
                abastecimento = Abastecimento.new
                #abastecimento.bomba = numero_bomba
                abastecimento.bomba = rand(1..200)
                abastecimento.valor = rand(0.0...250.0).round(2)
                abastecimento.combustivel = ["Etanol", "Gasolina"].sample
                #publicando na fila o abastecimento
                channel.default_exchange.publish(abastecimento.to_json, routing_key: queue.name)
                #informando que a publicação foi efetuada
                puts " [x] Sent #{abastecimento.to_json}"
                #aguardando 50 segundos para que o proximo carro entre na bomba
                sleep(50)
            end
        #end
        #threads << thr
    #end
    #threads.each { |thr| thr.join }
rescue Interrupt => _
    #fechando a conexão com o servidor de fila
    connection.close
end
#script criado para ser simples e direto, apenas um semeador de dados na fila