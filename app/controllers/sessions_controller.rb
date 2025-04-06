class SessionsController < ApplicationController
    def new
    # Renders the login form
    end

    def create
        email = params[:session][:email]&.downcase&.strip
        password = params[:session][:password]
        
        Rails.logger.info "Attempting login with email: #{email}"
        user = User.find_by(email: email)

        if user
            Rails.logger.info "User found: #{user.email}"
            if user.authenticate(password)
                Rails.logger.info "Password authentication successful"
                session[:user_id] = user.id
                flash[:notice] = "Logged in successfully"
                redirect_to root_path
            else
                Rails.logger.warn "Password authentication failed for user: #{user.email}"
                flash.now[:alert] = "Invalid email or password"
                render :new, status: :unprocessable_entity
            end
        else
            Rails.logger.warn "No user found with email: #{email}"
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
