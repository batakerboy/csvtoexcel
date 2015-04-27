class AddingIndexToAttendances < ActiveRecord::Migration
  def up
  	add_index(:attendances, [:last_name, :first_name, :attendance_date], name: 'by_last_name_first_name_and_date')
  end
end
