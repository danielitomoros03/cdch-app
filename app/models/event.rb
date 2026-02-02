# == Schema Information
#
# Table name: events
#
#  id          :bigint           not null, primary key
#  active      :boolean
#  day         :date
#  description :text
#  end_time    :time
#  kind        :integer
#  location    :string
#  show_in     :boolean
#  start_time  :time
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Event < ApplicationRecord
    ## Aditional Data
    has_rich_text :content
    has_one_attached :image

    ## ENUM KIND
    enum kind: [ :Noticia, :Ahora, :Eventualidad, :Jornada, :Otro ]
end
