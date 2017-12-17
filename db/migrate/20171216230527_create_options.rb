class CreateOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :options do |t|
      t.string :working_time, default:'18:00 - 24:00'
      t.boolean :active, default: true
      t.string :intro, null: false

      t.timestamps
    end
  end
end
