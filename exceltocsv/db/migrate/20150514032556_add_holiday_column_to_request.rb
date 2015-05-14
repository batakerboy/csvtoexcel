class AddHolidayColumnToRequest < ActiveRecord::Migration
  def change
  	add_column :requests, :is_holiday, :boolean
  end
end
