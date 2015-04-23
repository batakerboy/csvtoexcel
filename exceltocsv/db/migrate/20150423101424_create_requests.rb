class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :name
      t.string :department
      t.date :date
      t.decimal :ot_hours
      t.time :ut_time
      t.decimal :vacation_leave
      t.decimal :sick_leave
      t.decimal :official_business
      t.text :remarks

      t.timestamps null: false
    end
  end
end
