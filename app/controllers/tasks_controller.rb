class TasksController < ApplicationController
    before_action :require_login
    before_action :set_task, only: [:show, :edit, :update, :destroy, :toggle_status]
    before_action :authorize_user, only: [:show, :edit, :update, :destroy, :toggle_status]
  
    def index
      @tasks = current_user.tasks
      
      # Apply filters
      if params[:category].present? && params[:category] != "All Categories"
        if params[:category] == "Uncategorized"
          @tasks = @tasks.where('category IS NULL OR category = ?', '')
        else
          @tasks = @tasks.where(category: params[:category])
        end
      end
      
      if params[:priority].present? && params[:priority] != "All Priorities"
        priority_value = Task::PRIORITIES.key(params[:priority].downcase.gsub(' ', '_'))
        @tasks = @tasks.where(priority: priority_value)
      end
      
      if params[:status].present? && params[:status] != "All Statuses"
        @tasks = @tasks.where(status: params[:status].downcase.gsub(' ', '_'))
      end

      # Apply sorting
      @sort_column = params[:sort] || 'created_at'
      @sort_direction = params[:direction] || 'desc'
      
      # Validate sort column to prevent SQL injection
      valid_columns = ['title', 'category', 'priority', 'status', 'due_date', 'created_at']
      @sort_column = 'created_at' unless valid_columns.include?(@sort_column)
      
      @tasks = @tasks.order("#{@sort_column} #{@sort_direction}")
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
        redirect_to tasks_path
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
        redirect_to tasks_path
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
          redirect_to tasks_path
        end
    end
  
    def toggle_status
      new_status = @task.status == 'completed' ? 'pending' : 'completed'
      
      if @task.update(status: new_status)
        flash[:notice] = "Task marked as #{new_status}"
        redirect_to tasks_path
      else
        flash[:alert] = @task.errors.full_messages.join(", ")
        redirect_to @task
      end
    end
  
    private
  
    def task_params
      params.require(:task).permit(:title, :description, :priority, :status, :category, :due_date)
    end
  
    def set_task
      @task = Task.find_by(id: params[:id])
      unless @task
        flash[:alert] = "Task not found"
        redirect_to tasks_path and return
      end
    end
  
    def authorize_user
      unless @task && @task.user_id == current_user.id
        flash[:alert] = "You're not authorized to access this task"
        redirect_to tasks_path
      end
    end
end
  