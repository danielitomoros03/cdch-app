# Cargo en la nómina docente UCV (fuente: nómina de junio 2026).
# == Schema Information
#
# Table name: ucv_appointments
#
#  id                :bigint           not null, primary key
#  category          :string
#  category_code     :string
#  dedication        :string
#  dedication_code   :string
#  dependency        :string
#  dependency_code   :string
#  hired_on          :date
#  payroll_type      :string
#  payroll_type_code :string
#  retired_on        :date
#  source            :string
#  ucv_unit_code     :string
#  ucv_unit_name     :string
#  years_at_ucv      :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  person_id         :bigint           not null
#
# Indexes
#
#  index_ucv_appointments_on_person_id      (person_id)
#  index_ucv_appointments_on_ucv_unit_code  (ucv_unit_code)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id) ON DELETE => cascade
#
class UcvAppointment < ApplicationRecord
  belongs_to :person
  belongs_to :ucv_unit, foreign_key: :ucv_unit_code, primary_key: :code, optional: true
end
