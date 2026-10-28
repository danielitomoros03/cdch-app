# == Schema Information
#
# Table name: person_contacts
#
#  id         :bigint           not null, primary key
#  kind       :string           not null
#  source     :string
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  person_id  :bigint           not null
#
# Indexes
#
#  index_person_contacts_on_person_id                     (person_id)
#  index_person_contacts_on_person_id_and_kind_and_value  (person_id,kind,value) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id) ON DELETE => cascade
#
class PersonContact < ApplicationRecord
  KINDS = %w[email phone address].freeze

  belongs_to :person

  validates :kind, inclusion: { in: KINDS }
  validates :value, presence: true
end
