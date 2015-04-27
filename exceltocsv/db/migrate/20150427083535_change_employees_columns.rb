class ChangeEmployeesColumns < ActiveRecord::Migration
  def change
  	remove_column :employees, :status, :string
  	add_column :employees, :biometrics_id, :integer
  	add_column :employees, :falco_id, :integer
  end
end
