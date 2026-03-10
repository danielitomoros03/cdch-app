# == Schema Information
#
# Table name: publications
#
#  id               :bigint           not null, primary key
#  author_name      :string
#  date_publication :date
#  description      :text
#  external_url     :string
#  kind             :integer          default("Otro")
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Publication < ApplicationRecord
    has_one_attached :publication_field
    has_one_attached :portrait

    validates :title, presence: true
    validates :author_name, presence: true
    validates :description, presence: true
    validates :date_publication, presence: true
    validates :external_url,
                        presence: true,
                        format: {
                            with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                            message: "debe ser un enlace valido (http o https)"
                        }
    validate :portrait_must_be_attached
    validate :portrait_must_be_an_image

    enum kind: [:Otro, :Tesis, :Libro, :Revista, :Articulo]

    private

    def portrait_must_be_attached
        errors.add(:portrait, "debe cargarse como portada") unless portrait.attached?
    end

    def portrait_must_be_an_image
        return unless portrait.attached?
        return if portrait.content_type.in?(%w[image/png image/jpeg image/jpg image/webp])

        errors.add(:portrait, "debe ser una imagen JPG, PNG o WEBP")
    end
end

