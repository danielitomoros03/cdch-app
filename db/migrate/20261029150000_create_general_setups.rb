# Configuración general que maneja la DTIC desde el panel: funciones que se encienden
# o apagan sin desplegar de nuevo. Una sola fila.
class CreateGeneralSetups < ActiveRecord::Migration[7.2]
  def change
    create_table :general_setups do |t|
      t.integer :singleton, null: false, default: 1, index: { unique: true }
      t.boolean :teacher_space_enabled, null: false, default: false
      t.boolean :email_delivery_enabled, null: false, default: false
      t.references :updated_by, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
