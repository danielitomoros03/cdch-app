# Una publicación de Saber atribuida a una persona de cdch-app por Saber::AuthorMatcher:
# por su nombre (solo coincidencias seguras) o por un correo suyo que Saber publica.
# El docente puede decir desde "Mi espacio" que no es suya.
# == Schema Information
#
# Table name: saber_authorships
#
#  id            :bigint           not null, primary key
#  author_name   :string
#  matched_by    :string           not null
#  rejected_at   :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  person_id     :bigint           not null
#  saber_item_id :bigint           not null
#
# Indexes
#
#  index_saber_authorships_on_person_id                    (person_id)
#  index_saber_authorships_on_saber_item_id                (saber_item_id)
#  index_saber_authorships_on_saber_item_id_and_person_id  (saber_item_id,person_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#  fk_rails_...  (saber_item_id => saber_items.id)
#
class SaberAuthorship < ApplicationRecord
  MATCHED_BY = { "nombre" => "por nombre", "correo" => "por correo" }.freeze

  belongs_to :saber_item
  belongs_to :person

  validates :matched_by, inclusion: { in: MATCHED_BY.keys }

  scope :accepted, -> { where(rejected_at: nil) }
  scope :rejected, -> { where.not(rejected_at: nil) }
  scope :visible, -> { accepted.joins(:saber_item).merge(SaberItem.current) }
  scope :newest_first, -> { joins(:saber_item).order(Arel.sql("saber_items.issued_year DESC NULLS LAST, saber_items.title")) }

  def rejected?
    rejected_at.present?
  end

  def audit_label
    saber_item&.title.to_s.truncate(90)
  end
end
