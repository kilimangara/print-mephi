class CreateOrderLines < ActiveRecord::Migration[5.1]
  def change
    create_table :order_lines do |t|
      t.belongs_to :order, index: true
      t.string :name, null: false
      t.integer :price, default: 0
      t.integer :quantity, default: 1

      t.timestamps
    end
  end
end
