class AddExternalUrlToPublications < ActiveRecord::Migration[7.2]
  def change
    add_column :publications, :external_url, :string
  end
end
