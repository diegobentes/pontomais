class CreateVendas < ActiveRecord::Migration[6.0]
  def change
    create_table :vendas do |t|
      t.integer :bomba
      t.float :valor
      t.string :combustivel

      t.timestamps
    end
  end
end
