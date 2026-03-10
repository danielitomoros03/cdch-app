json.extract! publication, :id, :title, :author_name, :date_publication, :kind, :description, :external_url, :created_at, :updated_at
json.url publication_url(publication, format: :json)
