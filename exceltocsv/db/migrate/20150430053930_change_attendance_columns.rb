class ChangeAttendanceColumns < ActiveRecord::Migration
  def change
  	remove_column :attendances, :last_name, :string
  	remove_column :attendances, :first_name, :string
  	add_column :attendances, :employee_id, :string
  end
end
