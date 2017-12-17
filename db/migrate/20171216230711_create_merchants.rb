class CreateMerchants < ActiveRecord::Migration[5.1]
  def change
    create_table :merchants do |t|
      t.string :name, null: false
      t.integer :chat_id, unique: true
      t.string :link_to_tg, null: true
      t.string :phone, unique: true

      t.timestamps
    end
  end
end
