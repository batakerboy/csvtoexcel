class AddOffsetColumnToRequests < ActiveRecord::Migration
  def change
  	add_column :requests, :offset, :string
  end
end
