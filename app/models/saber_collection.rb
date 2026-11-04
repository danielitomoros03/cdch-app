# Comunidad (com_…) o colección (col_…) de Saber-UCV, con su nombre.
# == Schema Information
#
# Table name: saber_collections
#
#  id         :bigint           not null, primary key
#  name       :string
#  spec       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_saber_collections_on_spec  (spec) UNIQUE
#
class SaberCollection < ApplicationRecord
  validates :spec, presence: true, uniqueness: true

  def self.names_for(specs)
    where(spec: specs).pluck(:spec, :name).to_h
  end
end
