#script que simula as bombas transmitindo os dados para uma fila
#passara um carro a cada 50 segundos para abastecer pela bomba
#uma media de 72 carros por hora em cada bomba

#impotando classe de Abastecimento
require './class/Abastecimento.rb'
require './class/RabbitMQ.rb'

# rabbitmq = RabbitMQ.new(:queue => "abastecimentos")
# rabbitmq.open_connection
# rabbitmq.create_channel
# rabbitmq.create_queue
rabbitmq = RabbitMQ::init_express(:queue => "abastecimentos")

#array que recebera as threads
#threads = []

begin
    puts ' [*] Abastecendo... Pressione CTRL+C para encerrar'
    #gerando threads de acordo com a quantidade de bombas informadas (para uma execucao paralela ao codigo do requisito)
    #(ARGV[0].to_i..ARGV[1].to_i).each do |numero_bomba| 
        #thr = Thread.new do
            loop do
                abastecimento = Abastecimento.new
                abastecimento.bomba = rand(1..200)
                abastecimento.valor = rand(0.0...250.0).round(2)
                abastecimento.combustivel = ["Etanol", "Gasolina"].sample

                rabbitmq.produce_queue(abastecimento.to_json)
                puts " [x] Sent #{abastecimento.to_json}"
                #aguardando 50 segundos para que o proximo carro entre na bomba
                sleep(1)
            end
        #end
        #threads << thr
    #end
    #threads.each { |thr| thr.join }
rescue Interrupt => _
    #fechando a conexão com o servidor de fila
    rabbitmq.close_connection
end
#script criado para ser simples e direto, apenas um semeador de dados na fila