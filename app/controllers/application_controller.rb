class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

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
end
