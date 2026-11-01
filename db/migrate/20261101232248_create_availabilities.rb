class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :membership, null: false, foreign_key: true
      t.integer :day_of_week, null: false # Days of the week are from 0 (Sunday) to 6 (Saturday)
      # Using starting time and ending time per availability window so you can have multiple availabilities per day
      t.time :start_time, null: false
      t.time :end_time, null: false
      # This is to know when created / last updated
      t.timestamps
    end

    add_index :availabilities,
              [:membership_id, :day_of_week, :start_time, :end_time],
              unique: true,
              name: "index_availabilities_on_membership_and_window"
  end
end