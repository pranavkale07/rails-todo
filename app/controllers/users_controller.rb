class UsersController < ApplicationController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :require_login, only: [:edit, :update, :destroy]
    before_action :authorize_user, only: [:edit, :update, :destroy]

    def new
        @user = User.new
    end

    def create
        @user = User.new(user_params)
    
        if @user.save
          session[:user_id] = @user.id
          flash[:notice] = "Welcome, #{@user.username}!"
          redirect_to root_path
        else
          Rails.logger.info "🚨 Validation Errors: #{@user.errors.full_messages.join(", ")}"
          flash.now[:alert] = @user.errors.full_messages.join(", ")
    
          respond_to do |format|
            format.html { render :new, status: :unprocessable_entity }
            format.turbo_stream do
              render turbo_stream: turbo_stream.update("flash_message", partial: "shared/flash_message")
            end
          end
        end
    end

    def show
        # Optional — show user profile
    end

    def edit
    end

    def update
        if @user.update(user_params)
          flash[:notice] = "Profile updated successfully!"
          redirect_to @user
        else
          Rails.logger.info "🚨 Update Errors: #{@user.errors.full_messages.join(", ")}"
          flash.now[:alert] = @user.errors.full_messages.join(", ")
    
          respond_to do |format|
            format.html { render :edit, status: :unprocessable_entity }
            format.turbo_stream do
              render turbo_stream: turbo_stream.update("flash_message", partial: "shared/flash_message")
            end
          end
        end
    end

    def destroy
        if @user.destroy
            session.delete(:user_id)
            flash[:notice] = "Account deleted successfully!"
            redirect_to root_path
        else
            flash[:alert] = "Failed to delete account. Please try again."
            redirect_to @user
        end
    end

    private

    def user_params
        params.require(:user).permit(:username, :email, :password)
    end

    def set_user
        @user = User.find_by(id: params[:id])
        unless @user
            flash[:alert] = "User not found"
            redirect_to root_path
        end
    end

    def authorize_user
        unless current_user == @user
            flash[:alert] = "You're not authorized to perform this action"
            redirect_to root_path
        end
    end
end
