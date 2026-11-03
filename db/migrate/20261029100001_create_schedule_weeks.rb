class CreateScheduleWeeks < ActiveRecord::Migration[8.1]
  def change
    create_table :schedule_weeks do |t|
      t.references :business, null: false, foreign_key: true
      t.date :week_start, null: false
      t.string :status, null: false, default: "draft"
      t.datetime :published_at

      t.timestamps
    end
    add_index :schedule_weeks, [ :business_id, :week_start ], unique: true
  end
end
