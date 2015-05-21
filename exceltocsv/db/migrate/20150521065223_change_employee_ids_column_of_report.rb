class ChangeEmployeeIdsColumnOfReport < ActiveRecord::Migration
  def change
  	remove_column :reports, :employee_ids, :string
  	add_column :reports, :employee_ids, :text
  end
end
