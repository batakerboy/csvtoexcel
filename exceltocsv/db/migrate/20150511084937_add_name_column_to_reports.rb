class AddNameColumnToReports < ActiveRecord::Migration
  def change
  	add_column :reports, :name, :string
  end
end