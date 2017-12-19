class CreateOrderValues < ActiveRecord::Migration[5.1]
  def change
    create_table :order_values do |t|
      t.belongs_to :order, index: true
      t.string :field_type, null: false
      t.string :value, null: true

      t.timestamps
    end
  end
end
