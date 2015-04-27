class ChangeColumnOfRequests < ActiveRecord::Migration
  def change
  	remove_column :requests, :name, :string
  	add_column :requests, :first_name, :string
  	add_column :requests, :last_name, :string
  end
end
