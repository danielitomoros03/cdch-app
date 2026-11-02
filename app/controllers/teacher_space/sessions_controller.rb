module TeacherSpace
  # Entrada con cédula + fecha de ingreso a la UCV (nómina 2026). La respuesta es la
  # misma exista o no la cédula, y cada cédula se bloquea tras varios intentos fallidos.
  class SessionsController < BaseController
    NO_MATCH = "Los datos no coinciden con la nómina docente de la UCV. Revisa la cédula y la fecha de ingreso que figura en tu constancia de trabajo.".freeze
    LOCKED = "Hubo demasiados intentos con esa cédula. Inténtalo de nuevo en una hora.".freeze

    rate_limit to: 20, within: 15.minutes, only: :create, with: -> { redirect_to new_teacher_session_path, alert: LOCKED }

    def new
      redirect_to teacher_space_path if current_teacher
    end

    def create
      id_number = Person.normalize_id_number(params[:id_number])
      hired_on = parse_date(params[:hired_on])

      if id_number.blank? || TeacherAccessAttempt.locked?(id_number)
        return render_failure(id_number.blank? ? NO_MATCH : LOCKED)
      end

      person = Person.find_by_identity(id_number, hired_on)
      if person
        TeacherAccessAttempt.clear(id_number)
        person.update_column(:space_activated_at, Time.current) unless person.space_activated_at
        start_teacher_session(person)
        Audit.record(:teacher_sign_in, item: person, actor: person, request: request, sensitive: false)
        redirect_to teacher_space_path
      else
        locked = TeacherAccessAttempt.record_failure(id_number)
        audit_failure(id_number, locked)
        render_failure(NO_MATCH)
      end
    end

    def destroy
      reset_session
      redirect_to new_teacher_session_path, notice: "Cerraste tu sesión."
    end

    private

    def parse_date(value)
      Date.iso8601(value.to_s)
    rescue Date::Error
      nil
    end

    # Si la cédula es de un docente, la línea de la bitácora queda en su nombre.
    def audit_failure(id_number, locked)
      details = { id_number: id_number }
      details[:attempts] = TeacherAccessAttempt::MAX_FAILURES if locked
      Audit.record(locked ? :teacher_locked : :teacher_sign_in_failed,
                   item: Person.find_by(id_number: id_number), request: request, details: details)
    end

    def render_failure(message)
      flash.now[:alert] = message
      render :new, status: :unprocessable_entity
    end
  end
end
