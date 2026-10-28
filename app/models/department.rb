# == Schema Information
#
# Table name: departments
#
#  id             :bigint           not null, primary key
#  acronym        :string
#  code           :string
#  name           :string
#  official_name  :string
#  organize       :integer
#  public_visible :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  parent_id      :bigint
#
# Indexes
#
#  index_departments_on_code       (code) UNIQUE
#  index_departments_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => departments.id)
#
class Department < ApplicationRecord
    DIRECTION_ACRONYM = "Dir".freeze

    has_rich_text :description # Rich text association
    has_one_attached :logoDepartment # Active Storage association for logotype

    ## Associations (clasificador estructural del CDCH)
    belongs_to :parent, class_name: "Department", optional: true
    has_many :children, class_name: "Department", foreign_key: :parent_id, dependent: :restrict_with_error

    ## Scopes
    scope :publicly_visible, -> { where(public_visible: true) }

    ## Validations
    validates :acronym, presence: true, uniqueness: true
    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
    validates :organize, presence: true, uniqueness: true
    validates :code, uniqueness: true, format: { with: /\A\d{10}\z/, message: "debe tener 10 dígitos" }, allow_blank: true
    validate :parent_cannot_be_itself
    # validates :logoDepartment, presence: true

    def self.direction
        find_by!(acronym: DIRECTION_ACRONYM)
    end

    def send_director
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Director").id)
    end
    def send_subdirector
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Subdirector").id)
    end
    def send_jefe
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Jefe de Departamento").id)
    end
    def send_coordinador
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Coordinador").id)
    end
    def send_admin
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Personal Administrativo").id)
    end
    def send_secretary
        User.find_by(department_id: self.id, job_title_id: JobTitle.find_by(name: "Secreatario(a)").id)
    end

    private
    def parent_cannot_be_itself
        errors.add(:parent, "no puede ser el mismo departamento") if parent_id.present? && parent_id == id
    end

    def cut_acronym
        self.acronym = self.acronym.upcase
    end
end
