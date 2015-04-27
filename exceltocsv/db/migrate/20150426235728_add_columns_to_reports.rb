class AddColumnsToReports < ActiveRecord::Migration
  def change
  	remove_column :reports, :name, :string
  	add_column :reports, :attendance_id, :integer
  	add_column :reports, :request_id, :integer
  end
end
