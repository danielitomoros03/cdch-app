# Arbitrajes del sistema FoxPro (Dbf_priv/arbitro.DBF, 1989–2012). Confidenciales:
# solo Dirección y Subdirección los ven (ver Ability). Se llenan con `rails cdch:import`.
class CreatePeerReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :peer_reviews do |t|
      t.references :department, null: false, foreign_key: true
      t.integer :legacy_id, null: false, index: { unique: true }
      t.references :project_stage, foreign_key: true
      t.references :institutional_aid, foreign_key: true
      t.string :legacy_code
      t.integer :stage_number
      t.references :reviewer_person, foreign_key: { to_table: :people }
      t.string :reviewer_name
      t.string :letter_number
      t.date :sent_on, index: true
      t.date :answered_on
      t.boolean :opinion_given
      t.boolean :ratified
      t.string :receipt
      t.text :notes
      t.timestamps
    end
  end
end
