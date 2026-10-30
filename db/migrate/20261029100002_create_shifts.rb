class CreateShifts < ActiveRecord::Migration[8.1]
  def change
    # Position is added by Story 4 (create and assign shifts).
    create_table :shifts do |t|
      t.references :schedule_week, null: false, foreign_key: true
      # The assigned employee; a shift may be unassigned.
      t.references :membership, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.text :notes

      t.timestamps
    end
  end
end
