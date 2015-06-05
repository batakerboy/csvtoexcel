class AddTimeInAndOutColumnsToEmployees < ActiveRecord::Migration
  def change
  	add_column :employees, :required_time_in, :time
  	add_column :employees, :required_time_out, :time
  end
end
