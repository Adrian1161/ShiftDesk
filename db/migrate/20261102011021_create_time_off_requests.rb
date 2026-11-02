class CreateTimeOffRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :time_off_requests do |t|
      t.references :membership, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end
  end
end
