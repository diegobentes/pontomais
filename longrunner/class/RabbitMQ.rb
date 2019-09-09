require 'bunny'

class RabbitMQ
    attr_accessor :hostname, :password, :user, :queue

    def initialize(options = {})
        #options => {:hostname, :password, :user, :queue}
        self.hostname = options[:hostname] || '157.245.133.11'
        self.password = options[:password] || "admin"
        self.user = options[:user] || "admin"
        self.queue = options[:queue] || "default"
    end

    def self.init_express(options = {})
        #options => {:hostname, :password, :user, :queue}
        rabbitmq = self.new(options)
        rabbitmq.open_connection
        rabbitmq.create_channel
        rabbitmq.create_queue
        return rabbitmq
    end

    def open_connection
        setConnection(
            Bunny.new(
                hostname: self.hostname, 
                password: self.password, 
                user: self.user
            )
        )
        connection = getConnection
        connection.start
    end

    def create_channel
        connection = getConnection
        setChannel(connection.create_channel)
    end

    def create_queue
        setQueue(getChannel.queue(self.queue))
    end

    def produce_queue(object_to_queue)
        getChannel.default_exchange.publish(object_to_queue, routing_key: getQueue.name)
    end

    def listen_queue(consumer_tag = 'consummer_default', &block) 
        getQueue.subscribe(consumer_tag: consumer_tag, manual_ack: true) do |delivery_info, properties, body|
            yield(delivery_info, properties, body)
        end
    end

    def self.close_connection
        close_connection
    end

    def close_connection
        getConnection.close
    end

    def getConnection
        @@connection
    end

    def getChannel
        @@channel
    end

    def getQueue
        @@queue
    end

    private 

        def setConnection(bunny_instance)
            @@connection = bunny_instance
        end

        def setChannel(channel_instance)
            @@channel = channel_instance
        end

        def setQueue(queue_instance)
            @@queue = queue_instance
        end
    
end