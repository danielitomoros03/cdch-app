# Beca académica o al exterior (listados de DADA).
# == Schema Information
#
# Table name: scholarships
#
#  id                :bigint           not null, primary key
#  approved_on       :date
#  country           :string
#  dedication        :string
#  degree_filed_on   :date
#  dependency        :string
#  ends_on           :date
#  faculty           :string
#  file_number       :string
#  follow_up         :text
#  institution       :string
#  last_extension_on :date
#  level             :string
#  notes             :text
#  program           :string
#  rank              :string
#  scholarship_type  :string
#  source            :string
#  specialty         :string
#  starts_on         :date
#  status            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  department_id     :bigint           not null
#  legacy_id         :integer          not null
#  person_id         :bigint           not null
#
# Indexes
#
#  index_scholarships_on_department_id  (department_id)
#  index_scholarships_on_legacy_id      (legacy_id) UNIQUE
#  index_scholarships_on_person_id      (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (person_id => people.id)
#
class Scholarship < ApplicationRecord
  belongs_to :department
  belongs_to :person
end
