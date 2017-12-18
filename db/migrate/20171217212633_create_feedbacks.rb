class CreateFeedbacks < ActiveRecord::Migration[5.1]
  def change
    create_table :feedbacks do |t|
      t.belongs_to :client, index: true, null: true
      t.string :text, null: false
      t.integer :rate, default: 5

      t.timestamps
    end
  end
end
