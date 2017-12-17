class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.integer :position, null: false
      t.string :name, null: false
      t.boolean :hidden, default: true
      t.integer :parent_category_id, index: true

      t.timestamps
    end
  end
end
