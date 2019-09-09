require 'rubygems'
require 'win32/daemon'

require 'date'

require 'E:\\DiegoBentes\\pontomais\\longrunner\\class\\RabbitMQ.rb'
require 'rest-client'
require 'json'
include Win32

class RMQDaemon < Daemon

    def service_main
        begin
            log 'started'

            rabbitmq = RabbitMQ::init_express(:queue => "abastecimentos")
            log ' [*] Aguardando por abastecimentos'

            rabbitmq.listen_queue('WSPosto') do |delivery_info, properties, body|
                log " [x] Received #{body}"
                try = 1
                begin
                    log 'Iniciando chamada a API...'
                    response = RestClient.post('http://localhost:3000/vendas', {venda: JSON.parse(body)})
                    log "Resposta: #{response.inspect}"
                    if response.code == 201 then
                        log 'Mensagem Processada!'
                        rabbitmq.getChannel.ack(delivery_info.delivery_tag)
                    else
                        log "Erro ao processar a mensagem: #{body}"
                        rabbitmq.getChannel.nack(delivery_info.delivery_tag)
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
                rescue StandardError => e
                    log e.class
                    log e
                end
            end

            while running?
                sleep 5
            end
        rescue StandardError => e
            log e.class
            log e
        end
    end

    def service_stop
        log 'ended'
        exit!
    end

    def log(text)
        File.open(File.expand_path("../log.txt", ENV["OCRA_EXECUTABLE"] || __FILE__) , 'a') { |f| f.puts "#{Time.now}: #{text}" }
    end

end

RMQDaemon.mainloop unless defined?(Ocra)