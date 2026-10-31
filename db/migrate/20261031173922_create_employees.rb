class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :name
      t.references :business, null: false, foreign_key: true

      t.timestamps
    end
  end
end
