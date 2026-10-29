# Arbitraje de una etapa de proyecto (o, rara vez, de una ayuda): a quién se le envió,
# cuándo respondió y si emitió opinión. Confidencial: solo Dirección y Subdirección.
# == Schema Information
#
# Table name: peer_reviews
#
#  id                   :bigint           not null, primary key
#  answered_on          :date
#  legacy_code          :string
#  letter_number        :string
#  notes                :text
#  opinion_given        :boolean
#  ratified             :boolean
#  receipt              :string
#  reviewer_name        :string
#  sent_on              :date
#  stage_number         :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  department_id        :bigint           not null
#  institutional_aid_id :bigint
#  legacy_id            :integer          not null
#  project_stage_id     :bigint
#  reviewer_person_id   :bigint
#
# Indexes
#
#  index_peer_reviews_on_department_id         (department_id)
#  index_peer_reviews_on_institutional_aid_id  (institutional_aid_id)
#  index_peer_reviews_on_legacy_id             (legacy_id) UNIQUE
#  index_peer_reviews_on_project_stage_id      (project_stage_id)
#  index_peer_reviews_on_reviewer_person_id    (reviewer_person_id)
#  index_peer_reviews_on_sent_on               (sent_on)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (institutional_aid_id => institutional_aids.id)
#  fk_rails_...  (project_stage_id => project_stages.id)
#  fk_rails_...  (reviewer_person_id => people.id)
#
class PeerReview < ApplicationRecord
  belongs_to :department
  belongs_to :project_stage, optional: true
  belongs_to :institutional_aid, optional: true
  belongs_to :reviewer_person, class_name: "Person", optional: true

  normalizes :reviewer_name, with: ->(name) { name.squish.upcase }

  def reviewer_display_name
    reviewer_person&.display_name || Person.new(full_name: reviewer_name.to_s).display_name.presence || "—"
  end

  # Respondida sin opinión: por lo general el árbitro declinó.
  def outcome
    if opinion_given then "Emitió opinión"
    elsif answered_on then "Respondió sin opinión"
    else "Sin respuesta registrada"
    end
  end
end
