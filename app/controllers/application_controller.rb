class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def require_login
    redirect_to new_session_path, alert: "Please sign in first." unless current_user
  end

  def authorize_business_access
    business - Business.find_by(id: params[:business_id] || params[:id])
    unless current_user && current_user.businesses.include?(business)
      flash[:alert] = "Access denied to another business's data."
      redirect_to root_path
    end
  end

  def authorize_manager
    unless current_user&.manager? # UPDATE ME WITH MANAGER CONDITION AFTER ADDING ROLE TO EMPLOYES TABLE
      flash[:alert] = "Unauthorized"
      redirect_to root_path
    end
  end
end
