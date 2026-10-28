class AddStructuralClassifierToDepartments < ActiveRecord::Migration[7.2]
  def change
    add_column :departments, :code, :string
    add_column :departments, :official_name, :string
    add_column :departments, :public_visible, :boolean, default: true, null: false
    add_reference :departments, :parent, foreign_key: { to_table: :departments }

    add_index :departments, :code, unique: true
  end
end
