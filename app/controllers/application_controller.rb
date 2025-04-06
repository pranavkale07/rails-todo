class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      respond_to do |format|
        format.html do
        flash[:alert] = "You must be logged in to perform this action"
        redirect_to login_path
        end
        
        format.json do
        render json: { error: "You must be logged in to perform this action" }, status: :unauthorized
        end
      end
    end
  end
  
end
