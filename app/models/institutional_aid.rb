# Ayuda institucional (AI, AIA, AIB, AIE) del sistema heredado.
# == Schema Information
#
# Table name: institutional_aids
#
#  id                  :bigint           not null, primary key
#  aid_type_code       :string
#  amount_approved     :decimal(20, 2)
#  amount_equipment    :decimal(20, 2)
#  amount_flagged      :boolean          default(FALSE), not null
#  amount_other        :decimal(20, 2)
#  amount_requested    :decimal(20, 2)
#  amount_services     :decimal(20, 2)
#  amount_supplies     :decimal(20, 2)
#  amount_travel       :decimal(20, 2)
#  approved_on         :date
#  code                :string
#  currency            :string
#  dependency          :string
#  description         :text
#  duration_months     :integer
#  extension_code      :integer
#  extension_on        :date
#  faculty_code        :string
#  funding_source_code :string
#  legacy_code         :string
#  merge_note          :string
#  notes               :text
#  report_approved_on  :date
#  report_ok           :boolean
#  requested_on        :date
#  serial              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  applicant_person_id :bigint
#  department_id       :bigint           not null
#  legacy_id           :integer          not null
#  legacy_status_id    :bigint
#
# Indexes
#
#  index_institutional_aids_on_aid_type_code        (aid_type_code)
#  index_institutional_aids_on_applicant_person_id  (applicant_person_id)
#  index_institutional_aids_on_department_id        (department_id)
#  index_institutional_aids_on_legacy_id            (legacy_id) UNIQUE
#  index_institutional_aids_on_legacy_status_id     (legacy_status_id)
#  index_institutional_aids_on_requested_on         (requested_on)
#
# Foreign Keys
#
#  fk_rails_...  (applicant_person_id => people.id)
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (legacy_status_id => legacy_statuses.id)
#
class InstitutionalAid < ApplicationRecord
  include LegacyAmounts

  belongs_to :department
  belongs_to :applicant_person, class_name: "Person", optional: true
  belongs_to :legacy_status, optional: true
  belongs_to :project_type, foreign_key: :aid_type_code, primary_key: :code, optional: true
end
