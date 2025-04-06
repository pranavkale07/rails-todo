class SessionsController < ApplicationController
    def new
    # Renders the login form
    end

    def create
        user = User.find_by(email: params[:email]&.downcase&.strip)

        if user&.authenticate(params[:password])
            session[:user_id] = user.id
            flash[:notice] = "Logged in successfully"
            redirect_to root_path
        else
            flash.now[:alert] = "Invalid email or password"
            render :new, status: :unprocessable_entity
        end
    end

    def destroy
        if session[:user_id]
          session.delete(:user_id)
          flash[:notice] = "Logged out successfully"
        else
          Rails.logger.warn "⚠️ Logout attempt with no user logged in"
          flash[:alert] = "You are not logged in"
        end
        redirect_to login_path
    end
end
