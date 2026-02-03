class CreateInstitutions < ActiveRecord::Migration[7.2]
  def change
    create_table :institutions do |t|
      t.string :address
      t.string :name
      t.string :primary_phone
      t.string :secondary_phone
      t.string :primary_email
      t.string :secondary_email
      t.string :business_hours
      t.text :mission
      t.text :vission
      t.string :twitter_url
      t.string :facebook_url
      t.string :instagram_url
      t.string :threads_url
      t.string :acronym
      t.text :description
      t.string :linkedin_url
      t.string :director_name
      t.string :director_primary_email
      t.string :director_secondary_email
      t.string :subdirector_name
      t.string :subdirector_primary_email
      t.string :subdirector_secondary_email
      t.integer :founded_year

      t.timestamps
    end
  end
end
