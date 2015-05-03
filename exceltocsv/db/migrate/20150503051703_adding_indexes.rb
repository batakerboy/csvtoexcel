class AddingIndexes < ActiveRecord::Migration
  def change
  	add_index(:attendances, [:employee_id, :attendance_date], name: 'by_employee_and_date_attendance')
  	add_index(:requests, [:employee_id, :date], name: 'by_employee_and_date_request')
  	remove_column :reports, :attendance_id, :integer
  	remove_column :reports, :request_id, :integer
  	add_column :reports, :date_start, :date
  	add_column :reports, :date_end, :date
  end
end
