# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  active                 :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  identification_number  :string
#  lastname               :string
#  locked_at              :datetime
#  name                   :string
#  number_phone           :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  department_id          :bigint           default(0), not null
#  job_title_id           :bigint           default(0), not null
#
# Indexes
#
#  index_users_on_department_id         (department_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_job_title_id          (job_title_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
class User < ApplicationRecord
  # Lockable: 5 failed sign-ins lock the account for an hour (or until DTIC unlocks it).
  # Timeoutable: the session ends after an hour without activity.
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :lockable, :timeoutable
  
  ## Associations
  belongs_to :job_title
  belongs_to :department
  has_many :user_permissions, dependent: :destroy

  has_one_attached :photoUser # Active Storage association for user avatar

  ## Validations
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :lastname, presence: true
  validates :job_title_id, presence: true
  validates :department_id, presence: true
  validates :identification_number, presence: true, uniqueness: true
  validates :number_phone, presence: true, uniqueness: true
  # validates :avatarUser, presence: true

  # Delegate rol for access simple: user.role
  delegate :role, to: :job_title, allow_nil: true
  delegate :name, to: :department, prefix: true, allow_nil: true
  delegate :name, to: :role, prefix: true, allow_nil: true


  def full_name
    name + ' ' + lastname
  end
end
