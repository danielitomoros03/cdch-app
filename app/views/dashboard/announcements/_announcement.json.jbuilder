json.extract! announcement, :id, :content, :is_active, :created_at, :updated_at
json.url announcement_url(announcement, format: :json)
