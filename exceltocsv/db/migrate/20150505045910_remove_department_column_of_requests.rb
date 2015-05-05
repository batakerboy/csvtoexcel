class RemoveDepartmentColumnOfRequests < ActiveRecord::Migration
  def change
  	remove_column :requests, :department, :string
  end
end
