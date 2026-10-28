# Unidades ejecutoras de la UCV (10 dígitos; el CDCH es 27xxxxxxxx).
# == Schema Information
#
# Table name: ucv_units
#
#  id         :bigint           not null, primary key
#  code       :string           not null
#  name       :string
#  short_code :string
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_ucv_units_on_code  (code) UNIQUE
#
class UcvUnit < ApplicationRecord
  validates :code, presence: true, uniqueness: true
end
