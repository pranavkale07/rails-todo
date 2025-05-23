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
  
      respond_to do |format|
        if @task.save
          format.html do
            flash[:notice] = "Task created successfully!"
            redirect_to tasks_path
          end
          format.turbo_stream do
            flash.now[:notice] = "Task created successfully!"
            redirect_to tasks_path
          end
        else
          format.html do
            flash.now[:alert] = @task.errors.full_messages.join(", ")
            render :new, status: :unprocessable_entity
          end
          format.turbo_stream do
            flash.now[:alert] = @task.errors.full_messages.join(", ")
            render turbo_stream: turbo_stream.replace(
              "new_task_form",
              partial: "form",
              locals: { task: @task }
            )
          end
        end
      end
    end
  
    def edit
    end
  
    def update
      respond_to do |format|
        if @task.update(task_params)
          format.html do
            flash[:notice] = "Task updated successfully!"
            redirect_to tasks_path
          end
          format.json do
            render json: {
              success: true,
              message: "Task updated successfully"
            }
          end
        else
          format.html do
            flash.now[:alert] = @task.errors.full_messages.join(", ")
            render :edit, status: :unprocessable_entity
          end
          format.json do
            render json: {
              success: false,
              message: @task.errors.full_messages.join(", ")
            }, status: :unprocessable_entity
          end
        end
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
      
      respond_to do |format|
        if @task.update(status: new_status)
          format.html do
            flash[:notice] = "Task marked as #{new_status}"
            redirect_to tasks_path
          end
          format.json do
            render json: {
              success: true,
              message: "Task marked as #{new_status}",
              new_status: new_status
            }
          end
        else
          format.html do
            flash[:alert] = @task.errors.full_messages.join(", ")
            redirect_to @task
          end
          format.json do
            render json: {
              success: false,
              message: @task.errors.full_messages.join(", ")
            }, status: :unprocessable_entity
          end
        end
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
  