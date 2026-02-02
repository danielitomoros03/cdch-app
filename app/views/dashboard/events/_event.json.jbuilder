json.extract! event, :id, :title, :show_in, :active, :description, :kind, :day, :start_time, :end_time, :location, :created_at, :updated_at
json.url event_url(event, format: :json)
