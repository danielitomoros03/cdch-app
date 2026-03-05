class CreateUserPermissions < ActiveRecord::Migration[7.2]
  def change
    create_table :user_permissions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :resource, null: false

      t.timestamps
    end

    add_index :user_permissions, [:user_id, :resource], unique: true
  end
end
