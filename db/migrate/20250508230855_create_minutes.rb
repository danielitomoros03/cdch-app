class CreateMinutes < ActiveRecord::Migration[7.2]
  def change
    create_table :minutes do |t|
      t.date :day
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
