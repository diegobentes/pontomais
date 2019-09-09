require 'rubygems'
require 'win32/daemon'

require 'E:/DiegoBentes/pontomais/longrunner/class/RabbitMQ.rb'
require 'rest-client'
require 'json'

include Win32

class RMQDaemon < Daemon

    def service_main

        log 'started'        
        rabbitmq = RabbitMQ::init_express(:queue => "abastecimentos")
        log ' [*] Aguardando por abastecimentos'
        #timeout = 0

        rabbitmq.listen_queue('WSPosto') do |delivery_info, properties, body|
            log " [x] Received #{body}"
            # response = RestClient.post('http://localhost:3000/vendas', {venda: JSON.parse(body)})
            try = 1
            begin                
                response = RestClient.post('http://localhost:3000/vendas', {venda: JSON.parse(body)})
                if response.code == 201 then
                    log 'Mensagem Processada!'
                    rabbitmq.getChannel.ack(delivery_info.delivery_tag)
                    #RabbitMQ::ack(delivery_info)
                else
                    log "Erro ao processar a mensagem: #{body}"
                    getChannel.nack(delivery_info.delivery_tag)
                end
            rescue Errno::ECONNREFUSED => e
                log 'Conexão recusada com o servidor da API'
                if try == 3 then
                    log 'Após 3 tentativas não foi possível efetuar conexão.'
                    log "O erro retornado foi: #{e}"
                    log 'Tentando reconexão com o servidor em 15 segundos...'                    
                    sleep(15)
                    try = 1
                    retry
                else
                    try += 1
                    retry
                end
            end
        end
        # rescue Errno::ECONNREFUSED => e
            # log 'Conexão recusada com o servidor da API'
            # if timeout == 3 then
            #     log 'Por favor, verifique se o servidor de API está no ar, fechando conexão com o RabbitMQ...'
            #     rabbitmq.close_connection
            # else
            #     timeout += 1
            # end       
                
        while running?
            sleep(5)
        end  
        
    end

    def service_stop
        log 'ended'
        exit!
    end

    def log(text)
        File.open('E:/DiegoBentes/pontomais/longrunner/ws/log.txt', 'a') { |f| f.puts "#{Time.now}: #{text}" }
    end

end

RMQDaemon.mainloop

# rescue Interrupt => _
#     rabbitmq.close_connection
#     exit(0)
# rescue StandardError => e
#     log e
# end    