# Cuenta los intentos fallidos de entrar a "Mi espacio" por cédula. Tras MAX_FAILURES
# seguidos, esa cédula queda bloqueada LOCK_PERIOD, exista o no en la nómina.
# == Schema Information
#
# Table name: teacher_access_attempts
#
#  id           :bigint           not null, primary key
#  failures     :integer          default(0), not null
#  id_number    :string           not null
#  locked_until :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_teacher_access_attempts_on_id_number  (id_number) UNIQUE
#
class TeacherAccessAttempt < ApplicationRecord
  MAX_FAILURES = 5
  LOCK_PERIOD = 1.hour

  def self.locked?(id_number)
    where(id_number: id_number).where("locked_until > ?", Time.current).exists?
  end

  def self.record_failure(id_number)
    attempt = find_or_create_by!(id_number: id_number)
    attempt.with_lock do
      failures = attempt.failures + 1
      if failures >= MAX_FAILURES
        attempt.update!(failures: 0, locked_until: LOCK_PERIOD.from_now)
      else
        attempt.update!(failures: failures)
      end
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def self.clear(id_number)
    where(id_number: id_number).delete_all
  end
end
