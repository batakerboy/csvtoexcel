class ChangeColumnsOfRequests < ActiveRecord::Migration
  def change
  	change_column :requests, :sick_leave, :decimal, precision: 10, scale: 2
  	change_column :requests, :vacation_leave, :decimal, precision: 10, scale: 2
  	change_column :requests, :regular_ot, :decimal, precision: 10, scale: 2
  	change_column :requests, :rest_or_special_ot, :decimal, precision: 10, scale: 2
  	change_column :requests, :special_on_rest_ot, :decimal, precision: 10, scale: 2
  	change_column :requests, :regular_holiday_ot, :decimal, precision: 10, scale: 2
  	change_column :requests, :regular_on_rest_ot, :decimal, precision: 10, scale: 2
  end
end
