class AddYoutubeUrlToInstitutions < ActiveRecord::Migration[7.2]
  def change
    add_column :institutions, :youtube_url, :string
  end
end
