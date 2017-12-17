class CreateVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :variants do |t|
      t.string :name, null: false
      t.integer :price, default: 0
      t.belongs_to :product, index: true
      t.boolean :hidden, default: true
      t.boolean :has_fixed_price, default: false

      t.timestamps
    end
  end
end
