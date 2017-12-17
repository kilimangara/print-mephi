class CreateCustomFields < ActiveRecord::Migration[5.1]
  def change
    create_table :custom_fields do |t|
      t.string :field_type, null: false
      t.integer :destiny, null: false
      t.boolean :active, default: true
      t.boolean :required, default: true

      t.timestamps
    end
  end
end
