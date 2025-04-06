class TasksController < ApplicationController
    before_action :require_login
    before_action :set_task, only: [:show, :edit, :update, :destroy]
    before_action :authorize_user, only: [:show, :edit, :update, :destroy]
  
    def index
      @tasks = current_user.tasks.order(created_at: :desc)
    end
  
    def show
    end
  
    def new
      @task = current_user.tasks.build
    end
  
    def create
      @task = current_user.tasks.build(task_params)
  
      if @task.save
        flash[:notice] = "Task created successfully!"
        redirect_to @task
      else
        flash.now[:alert] = @task.errors.full_messages.join(", ")
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit
    end
  
    def update
      if @task.update(task_params)
        flash[:notice] = "Task updated successfully!"
        redirect_to @task
      else
        flash.now[:alert] = @task.errors.full_messages.join(", ")
        render :edit, status: :unprocessable_entity
      end
    end
  
    def destroy
        if @task.destroy
          flash[:notice] = "Task deleted successfully!"
          redirect_to tasks_path
        else
          Rails.logger.error "❌ Failed to delete task: #{@task.errors.full_messages.join(", ")}"
          flash[:alert] = "Failed to delete task: #{@task.errors.full_messages.join(", ")}"
          redirect_to @task
        end
    end
  
    private
  
    def task_params
      params.require(:task).permit(:title, :description, :priority, :status, :category, :due_date)
    end
  
    def set_task
        @task = Task.find_by!(id: params[:id])
    rescue ActiveRecord::RecordNotFound
        flash[:alert] = "Task not found"
        redirect_to tasks_path
    end
  
    def authorize_user
      unless @task.user_id == current_user.id
        flash[:alert] = "You're not authorized to access this task"
        redirect_to tasks_path
      end
    end
end
  