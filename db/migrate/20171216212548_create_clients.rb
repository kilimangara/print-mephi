class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.string :phone, unique: true
      t.string :name, null: true
      t.integer :chat_id

      t.timestamps
    end
  end
end
