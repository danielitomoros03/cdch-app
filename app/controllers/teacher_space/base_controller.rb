module TeacherSpace
  # Base de "Mi espacio": fuera de Devise y de CanCanCan. El docente solo ve lo suyo,
  # identificado por la sesión que abre SessionsController.
  class BaseController < ApplicationController
    IDLE_TIMEOUT = 30.minutes

    skip_before_action :authenticate_user!
    before_action :require_enabled
    layout "teacher_space"

    helper_method :current_teacher

    private

    def require_enabled
      raise ActionController::RoutingError, "Not Found" unless GeneralSetup.teacher_space?
    end

    def current_teacher
      return @current_teacher if defined?(@current_teacher)

      seen_at = session[:teacher_seen_at]
      @current_teacher = if session[:teacher_person_id] && seen_at && Time.zone.at(seen_at) > IDLE_TIMEOUT.ago
        session[:teacher_seen_at] = Time.current.to_i
        Person.find_by(id: session[:teacher_person_id])
      end
    end

    def require_teacher
      redirect_to new_teacher_session_path, alert: "Tu sesión terminó. Vuelve a entrar con tu cédula y tu fecha de ingreso." unless current_teacher
    end

    def start_teacher_session(person)
      reset_session
      session[:teacher_person_id] = person.id
      session[:teacher_seen_at] = Time.current.to_i
    end
  end
end
