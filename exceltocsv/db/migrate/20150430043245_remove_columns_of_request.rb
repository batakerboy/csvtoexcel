class RemoveColumnsOfRequest < ActiveRecord::Migration
  def change
  	remove_column :requests, :first_name, :string
  	remove_column :requests, :last_name, :string
  	add_column :requests, :employee_id, :string
  end
end
