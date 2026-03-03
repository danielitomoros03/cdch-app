class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
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
end
