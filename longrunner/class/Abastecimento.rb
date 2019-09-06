#Importando biblioteca de conversao de objeto em json
require 'json'

class Abastecimento
    attr_accessor :valor, :bomba, :combustivel

    def as_json(options={})
        {
            valor: @valor,
            bomba: @bomba,
            combustivel: @combustivel
        }
    end

    def to_json(*options)
        as_json(*options).to_json(*options)
    end

end