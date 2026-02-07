# == Schema Information
#
# Table name: publications
#
#  id               :bigint           not null, primary key
#  author_name      :string
#  date_publication :date
#  description      :text
#  kind             :integer          default("Otro")
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Publication < ApplicationRecord
    has_one_attached :publication_field  ## Attached
    # has_rich_text :description ## Rich Text Area
    
    ## Validations
    validates :title, presence: true
    validates :author_name, presence: true
    validates :description, presence: true
    validates :date_publication, presence: true
    # validates :publication_field, presence: true

    ## Enum for Kind Publication
    enum kind: [:Otro, :Tesis, :Libro, :Revista, :Articulo]
    
end

