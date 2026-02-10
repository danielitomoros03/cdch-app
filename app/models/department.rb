# == Schema Information
#
# Table name: departments
#
#  id         :bigint           not null, primary key
#  acronym    :string
#  name       :string
#  organize   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Department < ApplicationRecord
    has_rich_text :description # Rich text association
    has_one_attached :logoDepartment # Active Storage association for logotype

    ## Validations
    validates :acronym, presence: true, uniqueness: true
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
    validates :organize, presence: true, uniqueness: true
    # validates :logoDepartment, presence: true

    def send_director
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Director").id)
    end
    def send_subdirector
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Subdirector").id)
    end
    def send_jefe
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Jefe").id)
    end
    def send_coordinador
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Coordinador").id)
    end
    def send_admin
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Personal Administrativo").id)
    end
    def send_coordinador
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Coordinador").id)
    end
    def send_secretary
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Secreatario(a)").id)
    end
end
