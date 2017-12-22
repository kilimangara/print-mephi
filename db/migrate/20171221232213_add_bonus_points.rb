class AddBonusPoints < ActiveRecord::Migration[5.1]
  def change
    add_column :options, :action_active, :boolean, default: false
    add_column :options, :bonus_points, :integer, default: 100
    add_column :clients, :bonus_points, :integer, default: 0
    add_column :clients, :action_used, :boolean, default: false
  end
end
