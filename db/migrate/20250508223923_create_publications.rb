class CreatePublications < ActiveRecord::Migration[7.2]
  def change
    create_table :publications do |t|
      t.string :title
      t.string :author_name
      t.date :date_publication
      t.integer :kind, default: 0
      t.text :description

      t.timestamps
    end
  end
end
