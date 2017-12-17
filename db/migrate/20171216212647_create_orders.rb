class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.belongs_to :client, index: true
      t.integer :total, default: 0
      t.boolean :canceled, default: false
      t.belongs_to :delivery_variant, index: true

      t.timestamps
    end
  end
end
