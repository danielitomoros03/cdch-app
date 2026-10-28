# Subprogramas del sistema heredado: PI, PG, AIA... (proyectos y ayudas).
# == Schema Information
#
# Table name: project_types
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  current    :boolean          default(FALSE), not null
#  name       :string
#  program    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_project_types_on_code  (code) UNIQUE
#
class ProjectType < ApplicationRecord
  validates :code, presence: true, uniqueness: true
end
