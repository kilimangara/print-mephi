class AddFulfilledColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :fulfilled, :boolean, default: false
  end
end
