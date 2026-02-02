class CreateJobTitles < ActiveRecord::Migration[7.2]
  def change
    create_table :job_titles do |t|
      t.string :name
      t.integer :role

      t.timestamps
    end
  end
end
