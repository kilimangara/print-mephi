class CreateDeliveryVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :delivery_variants do |t|
      t.string :name, null: false
      t.string :description, null: true
      t.boolean :active, default: true
      t.integer :price, default: 0

      t.timestamps
    end
  end
end
