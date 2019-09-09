# begin

    require 'rubygems'
    require 'win32/service'
    include Win32

    Service.create({
    service_name: 'RMQConsumeQueue',
    host: 'localhost',
    service_type: Service::WIN32_OWN_PROCESS,
    description: 'Serviço para consumir filas do RabbitMQ',
    start_type: Service::AUTO_START,
    error_control: Service::ERROR_NORMAL,
    binary_path_name: "#{`where ruby`.chomp} #{`echo %cd%`.chomp}/Service.rb",
    #binary_path_name: "C:/Ruby25-x64/bin/ruby.exe -C E:/DiegoBentes/pontomais/longrunner/ws/service.rb",
    load_order_group: 'Network',
    dependencies: nil,
    display_name: 'RMQ C Queue'
    })

    Service.start("RMQConsumeQueue")

# rescue StandardError => e
#     File.open('E:/DiegoBentes/pontomais/longrunner/ws/log.txt', 'a') { |f| f.puts e }
# end