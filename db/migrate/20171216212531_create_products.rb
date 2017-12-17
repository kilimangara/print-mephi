class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :price, default: 0
      t.belongs_to :category, index: true
      t.boolean :hidden, default: true
      t.integer :position, null: false
      t.boolean :has_fixed_price, default: false

      t.timestamps
    end
  end
end
