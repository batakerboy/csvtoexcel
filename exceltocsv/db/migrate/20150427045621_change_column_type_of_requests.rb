class ChangeColumnTypeOfRequests < ActiveRecord::Migration
  def up
  	remove_column :requests, :official_business, :decimal
  	add_column :requests, :official_business, :string
  end
end
