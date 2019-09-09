require 'rubygems'
require 'win32/service'
include Win32

unless defined?(Ocra)
    Service.create({
        service_name: 'RMQConsumeQueue',
        host: 'localhost',
        service_type: Service::WIN32_OWN_PROCESS,
        description: 'Serviço para consumir filas do RabbitMQ',
        start_type: Service::AUTO_START,
        error_control: Service::ERROR_NORMAL,
        binary_path_name: "#{`echo %cd%`.chomp}\\service.exe",
        load_order_group: 'Network',
        dependencies: nil,
        display_name: 'RMQ C Queue'
    })

    Service.start("RMQConsumeQueue")
end