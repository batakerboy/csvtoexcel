class AddEmployeeIdsColumnToReport < ActiveRecord::Migration
  def change
  	drop_table :reports

  	create_table "reports", force: :cascade do |t|
	    t.datetime "created_at", null: false
	    t.datetime "updated_at", null: false
	    t.date     "date_start"
	    t.date     "date_end"
	    t.string   "name"
	 end
  	add_column :reports, :employee_ids, :string, array: true, default: []
  end
end
