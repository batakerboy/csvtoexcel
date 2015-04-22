class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.string :name
      t.date :attendance_date
      t.time :time_in
      t.time :time_out

      t.timestamps null: false
    end
  end
end
