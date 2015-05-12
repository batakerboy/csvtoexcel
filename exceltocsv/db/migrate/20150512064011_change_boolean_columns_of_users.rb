class ChangeBooleanColumnsOfUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :is_admin?, :boolean
  	remove_column :users, :is_active?, :boolean
  	add_column :users, :is_admin, :boolean
  	add_column :users, :is_active, :boolean
  end
end
