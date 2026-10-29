# "Mi espacio en el CDCH": el docente entra con su cédula y su fecha de ingreso a la UCV
# (nómina 2026), consulta su historia y mantiene al día sus datos de contacto.
class AddTeacherSpace < ActiveRecord::Migration[7.2]
  def change
    change_table :people, bulk: true do |t|
      t.string :orcid
      t.text :research_lines
      t.datetime :space_activated_at
    end

    # Intentos fallidos por cédula (exista o no), para frenar a quien pruebe fechas al azar.
    create_table :teacher_access_attempts do |t|
      t.string :id_number, null: false, index: { unique: true }
      t.integer :failures, null: false, default: 0
      t.datetime :locked_until
      t.timestamps
    end
  end
end
