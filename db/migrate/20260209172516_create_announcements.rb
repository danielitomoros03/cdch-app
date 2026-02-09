class CreateAnnouncements < ActiveRecord::Migration[7.2]
  def change
    create_table :announcements do |t|
      t.text :content
      t.boolean :is_active

      t.timestamps
    end
  end
end
