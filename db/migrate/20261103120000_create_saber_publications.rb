class CreateSaberPublications < ActiveRecord::Migration[7.2]
  def change
    # Copia de los metadatos públicos de Saber-UCV (DSpace), cosechados por OAI-PMH.
    create_table :saber_items do |t|
      t.string :handle, null: false
      t.text :title
      t.string :item_type
      # Tipo normalizado (SaberItem::KINDS): agrupa las variantes que trae Saber.
      t.string :kind, null: false, default: "otro"
      t.string :issued
      t.integer :issued_year
      t.string :language
      t.text :abstract
      t.string :doi
      t.jsonb :author_names, null: false, default: []
      t.jsonb :subjects, null: false, default: []
      t.jsonb :collection_specs, null: false, default: []
      # Correos que Saber publica en el ítem: solo sirven para vincular, no se muestran.
      t.jsonb :emails, null: false, default: []
      t.datetime :datestamp
      t.datetime :seen_at
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
    add_index :saber_items, :handle, unique: true
    add_index :saber_items, :datestamp
    add_index :saber_items, :kind

    create_table :saber_collections do |t|
      t.string :spec, null: false
      t.string :name
      t.timestamps
    end
    add_index :saber_collections, :spec, unique: true

    # Publicación de Saber ↔ persona de cdch-app. `matched_by`: "nombre" (coincidencia
    # segura) o "correo". Si el docente dice que no es suya queda `rejected_at` y el
    # vínculo no vuelve a crearse en las cosechas siguientes.
    create_table :saber_authorships do |t|
      t.references :saber_item, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.string :author_name
      t.string :matched_by, null: false
      t.datetime :rejected_at
      t.timestamps
    end
    add_index :saber_authorships, %i[saber_item_id person_id], unique: true
  end
end
