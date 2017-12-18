class CreateBlackLists < ActiveRecord::Migration[5.1]
  def change
    create_table :black_lists do |t|
      t.integer :chat_id, unique: true
      t.string :reason, null: false

      t.timestamps
    end
  end
end
