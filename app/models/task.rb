class Task < ApplicationRecord
    belongs_to :user
  
    enum priority: {
      very_high: 1,
      high: 2,
      medium: 3,
      low: 4,
      very_low: 5
    }

    enum status: {
        pending: "pending",
        in_progress: "in_progress",
        completed: "completed",
        cancelled: "cancelled"
    }

  
    # VALIDATIONS
    validates :user, presence: true
    validates :title, presence: true, length: { maximum: 100 }
    # validates :priority, inclusion: { in: priorities.keys }, allow_nil: true
    validates :priority, inclusion: { in: Task.priorities.keys }, allow_nil: true
    # validates :status, inclusion: { in: %w[pending in_progress completed cancelled] }  # handled automatically by rails
  
    # CALLBACKS
    before_validation :strip_title_and_category
    before_validation :set_default_priority
  
    private
  
        def strip_title_and_category
            self.title = title.strip if title.present?
            self.category = category.strip if category.present?
        end

        def set_default_priority
            self.priority ||= :medium
        end
  end
  