class AddIsActiveColumnToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :is_active?,
  end
end
