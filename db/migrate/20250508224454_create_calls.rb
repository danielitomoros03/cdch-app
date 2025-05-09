class CreateCalls < ActiveRecord::Migration[7.2]
  def change
    create_table :calls do |t|
      t.string :title, null: false
      t.string :short_description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :type
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
