class RemoveNameFromAttendances < ActiveRecord::Migration
  def change
  	remove_column :attendances, :name
  	add_column :attendances, :last_name, :string
  	add_column :attendances, :first_name, :string
  end
end
