class CreateUsersAndBusinesses < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :businesses do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true
      t.string :role, null: false
      t.timestamps
    end
    add_index :memberships, [:user_id, :business_id], unique: true

    create_table :invitations do |t|
      t.references :business, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.datetime :accepted_at
      t.timestamps
    end
  end
end
