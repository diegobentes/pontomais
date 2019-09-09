class VendasController < ApplicationController
  
  # GET /vendas
  def index
    vendas = Venda.all
    @bombas = {}
    vendas.each do |venda|
      if @bombas.key?(venda.bomba) then
        @bombas[venda.bomba][:valor] += venda.valor
        @bombas[venda.bomba][:quantidade] += 1
      else
        @bombas.merge!({venda.bomba => {:valor => venda.valor, :quantidade => 1}})
      end
    end

    render json: @bombas
  end

    # POST /vendas
  def create
    @venda = Venda.new(venda_params)

    if @venda.save
      render json: @venda, status: :created
    else
      render json: @venda.errors, status: :unprocessable_entity
    end
  end

  private

    def venda_params
      params.require(:venda).permit(:bomba, :valor, :combustivel)
    end
end
