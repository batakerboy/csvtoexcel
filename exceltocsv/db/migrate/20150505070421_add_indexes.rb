class AddIndexes < ActiveRecord::Migration
  def change
  	remove_index :attendances, name: "by_last_name_first_name_and_date"
  	add_index :employees, :falco_id, name: 'by_falco_id'
  	add_index :employees, :biometrics_id, name: 'by_biometrics_id'
  end
end
