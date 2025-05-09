class CreateDirectories < ActiveRecord::Migration[7.2]
  def change
    create_table :directories do |t|
      t.date :day
      t.string :title

      t.timestamps
    end
  end
end
