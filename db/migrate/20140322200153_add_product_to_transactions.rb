class AddProductToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :product, :string
  end
end
