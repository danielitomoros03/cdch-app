class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  layout -> {
    if turbo_frame_request? then "turbo_rails/frame"
    elsif controller_path.start_with?("dashboard") then "dashboard"
    end
  }
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :route_not_found

  def after_sign_in_path_for(resource)
    dashboard_index_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  # Authorization with CanCanCan
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to dashboard_index_path, alert: "No tienes permiso para acceder a esa sección."
  end

  def route_not_found
    respond_to do |format|
      format.html do
        if current_user.present?
          redirect_to dashboard_index_path, alert: "La vista solicitada no existe."
        else
          redirect_to root_path, alert: "La vista solicitada no existe."
        end
      end
      format.any { head :not_found }
    end
  end

  private

  # Bitácora: PaperTrail guarda con cada cambio quién lo hizo y desde dónde.
  def user_for_paper_trail
    paper_trail_actor&.id
  end

  def info_for_paper_trail
    Audit.request_context(request).merge(Audit.actor_info(paper_trail_actor).except(:whodunnit))
  end

  # En los controladores de Devise, preguntar por current_user antes de tiempo dispararía
  # la autenticación; sus eventos se registran en config/initializers/audit_sign_in.rb.
  def paper_trail_actor
    current_user unless devise_controller?
  end
end
