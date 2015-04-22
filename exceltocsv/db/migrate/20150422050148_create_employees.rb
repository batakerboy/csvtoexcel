class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :last_name
      t.string :first_name
      t.string :department
      t.string :status

      t.timestamps null: false
    end
  end
end
