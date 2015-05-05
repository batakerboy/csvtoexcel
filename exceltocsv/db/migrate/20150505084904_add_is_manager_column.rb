class AddIsManagerColumn < ActiveRecord::Migration
  def change
  	add_column :employees, :is_manager, :boolean
  end
end
