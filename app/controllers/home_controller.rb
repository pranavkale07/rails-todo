class HomeController < ApplicationController
  def index
    if current_user
      redirect_to tasks_path
    end
  end
end
