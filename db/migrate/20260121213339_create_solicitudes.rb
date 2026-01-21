class CreateSolicitudes < ActiveRecord::Migration[7.2]
  def change
    create_table :solicitudes do |t|
      t.string :full_name
      t.string :email
      t.string :phone_number
      t.integer :matter
      t.text :message
      t.boolean :policies, default: true

      t.timestamps
    end
  end
end
