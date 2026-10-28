# Nivel del Programa de Promoción al Investigador (registro de 2005).
# == Schema Information
#
# Table name: ppi_levels
#
#  id         :bigint           not null, primary key
#  committee  :string
#  level      :string
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  person_id  :bigint           not null
#
# Indexes
#
#  index_ppi_levels_on_person_id  (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id) ON DELETE => cascade
#
class PpiLevel < ApplicationRecord
  belongs_to :person
end
