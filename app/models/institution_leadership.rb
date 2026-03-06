# == Schema Information
#
# Table name: institution_leaderships
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(FALSE), not null
#  end_date       :date
#  full_name      :string           not null
#  role           :integer          default("director"), not null
#  start_date     :date             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint           not null
#
# Indexes
#
#  idx_inst_leadership_institution_role             (institution_id,role)
#  index_institution_leaderships_on_institution_id  (institution_id)
#  index_institution_leaderships_on_role            (role)
#  index_institution_leaderships_on_start_date      (start_date)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#
class InstitutionLeadership < ApplicationRecord
  belongs_to :institution

  has_one_attached :photo
  has_rich_text :bio

  enum role: { director: 0, subdirector: 1 }

  before_validation :set_active_from_dates

  validates :institution_id, presence: true
  validates :full_name, presence: true
  validates :role, presence: true
  validates :start_date, presence: true

  validate :end_date_after_start_date
  validate :no_overlapping_periods_for_same_role

  scope :ordered_for_gallery, lambda {
    order(:role)
      .order(Arel.sql("CASE WHEN end_date IS NULL THEN 0 ELSE 1 END"))
      .order(Arel.sql("COALESCE(end_date, DATE '9999-12-31') DESC"))
      .order(start_date: :desc, created_at: :desc)
  }

  def role_label
    director? ? "Director(a)" : "Subdirector(a)"
  end

  def period_label
    from = start_date.present? ? start_date.strftime("%Y") : "?"
    to = end_date.present? ? end_date.strftime("%Y") : "Actualidad"
    "#{from} - #{to}"
  end

  private

  def set_active_from_dates
    self.active = end_date.blank?
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    return unless end_date < start_date

    errors.add(:end_date, "debe ser mayor o igual a la fecha de inicio")
  end

  def no_overlapping_periods_for_same_role
    return if institution_id.blank? || role.blank? || start_date.blank?

    overlapping = self.class
                  .where(institution_id: institution_id, role: role)
                  .where.not(id: id)
                  .where(
                    "daterange(start_date, COALESCE(end_date, 'infinity'::date), '[]') && daterange(:start_date, COALESCE(:end_date, 'infinity'::date), '[]')",
                    start_date: start_date,
                    end_date: end_date
                  )

    return unless overlapping.exists?

    errors.add(:base, "Las fechas se solapan con otra autoridad del mismo cargo. Solo se permite solapamiento entre cargos distintos.")
  end
end
