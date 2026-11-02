# Bitácora: las versiones de PaperTrail más el contexto de quién, desde dónde y con qué.
# Un registro puede ser un cambio en un modelo (create/update/destroy) o un evento sin
# modelo detrás (un inicio de sesión fallido, una exportación), por eso item es opcional.
class CreateVersions < ActiveRecord::Migration[7.2]
  def change
    create_table :versions do |t|
      t.string :item_type
      t.bigint :item_id
      t.string :event, null: false
      t.string :whodunnit
      t.jsonb :object
      t.jsonb :object_changes
      t.datetime :created_at, null: false

      t.string :actor_type
      t.string :actor_label
      t.string :item_label
      t.boolean :sensitive, null: false, default: false
      t.jsonb :details, null: false, default: {}
      t.string :ip
      t.string :location
      t.string :os
      t.string :browser
      t.string :request_id
    end

    add_index :versions, %i[item_type item_id]
    add_index :versions, :created_at
    add_index :versions, %i[actor_type whodunnit]
    add_index :versions, :event
  end
end
