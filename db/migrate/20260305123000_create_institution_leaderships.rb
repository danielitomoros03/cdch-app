class CreateInstitutionLeaderships < ActiveRecord::Migration[7.2]
  def change
    create_table :institution_leaderships do |t|
      t.references :institution, null: false, foreign_key: true
      t.string :full_name, null: false
      t.integer :role, null: false, default: 0
      t.date :start_date, null: false
      t.date :end_date
      t.boolean :active, default: false, null: false

      t.timestamps
    end

    add_index :institution_leaderships, :role
    add_index :institution_leaderships, :start_date
    add_index :institution_leaderships, [:institution_id, :role], name: "idx_inst_leadership_institution_role"
  end
end
