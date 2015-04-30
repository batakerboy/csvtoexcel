class ChangeColumnTypesOfEmployees < ActiveRecord::Migration
  def change
  	remove_column :employees, :biometrics_id, :integer
  	remove_column :employees, :falco_id, :integer
  	add_column :employees, :biometrics_id, :string
  	add_column :employees, :falco_id, :string
  end
end
