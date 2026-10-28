# Estados de proyectos y ayudas en el sistema FoxPro del Dpto. de Proyectos.
# == Schema Information
#
# Table name: legacy_statuses
#
#  id         :bigint           not null, primary key
#  applies_to :string
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  legacy_id  :integer          not null
#
# Indexes
#
#  index_legacy_statuses_on_legacy_id  (legacy_id) UNIQUE
#
class LegacyStatus < ApplicationRecord
  validates :legacy_id, presence: true, uniqueness: true
  validates :name, presence: true
end
