class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :title
      t.boolean :show_in
      t.boolean :active
      t.text :description
      t.integer :kind
      t.date :day
      t.time :start_time
      t.time :end_time
      t.string :location

      t.timestamps
    end
  end
end
