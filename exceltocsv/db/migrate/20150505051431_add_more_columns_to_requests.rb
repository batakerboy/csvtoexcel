class AddMoreColumnsToRequests < ActiveRecord::Migration
  def change
  	remove_column :requests, :official_business, :string
  	remove_column :requests, :ot_hours, :decimal
  	add_column :requests, :ob_departure, :time
  	add_column :requests, :ob_time_start, :time
  	add_column :requests, :ob_time_end, :time
  	add_column :requests, :ob_arrival, :time
  	add_column :requests, :vacation_leave_balance, :string
  	add_column :requests, :sick_leave_balance, :string
  	add_column :requests, :regular_ot, :decimal
  	add_column :requests, :rest_or_special_ot, :decimal
  	add_column :requests, :special_on_rest_ot, :decimal
  	add_column :requests, :regular_holiday_ot, :decimal
  	add_column :requests, :regular_on_rest_ot, :decimal
  end
end
