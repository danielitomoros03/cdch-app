# == Schema Information
#
# Table name: job_titles
#
#  id         :bigint           not null, primary key
#  name       :string
#  role       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class JobTitle < ApplicationRecord
  # El cargo define el rol y con él los permisos: sus cambios son sensibles.
  audited sensitive: true

    ## Associations
    has_many :users
    # Mapeamos los nombres variados a roles lógicos para la gema
    enum role: [ :Regular, :Coordinador, :Administrador, :JefeDepartamento, :Superadmin, :Desarrollador ]
end
