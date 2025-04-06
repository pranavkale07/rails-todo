class Task < ApplicationRecord
    belongs_to :user
  
    PRIORITIES = {
      1 => 'very_high',
      2 => 'high',
      3 => 'medium',
      4 => 'low',
      5 => 'very_low'
    }.freeze
    STATUSES   = %w[pending in_progress completed cancelled]

    # SCOPES
    scope :completed, -> { where(status: 'completed') }
    scope :pending, -> { where(status: 'pending') }
    scope :overdue, -> { where('due_date < ? AND status != ?', Date.today, 'completed') }
  
    # VALIDATIONS
    validates :user, presence: true
    validates :title, presence: true, length: { maximum: 100 }

    # validates :priority, inclusion: { in: priorities.keys }, allow_nil: true
    # validates :priority, inclusion: { in: Task.priorities.keys }, allow_nil: true
    # validates :status, inclusion: { in: %w[pending in_progress completed cancelled] }  # handled automatically by rails

    validates :priority, presence: true, inclusion: { in: PRIORITIES.keys, message: "must be between 1 and 5" }
    validates :status, inclusion: { in: STATUSES }
  
    # CALLBACKS
    before_validation :strip_title_and_category
    before_validation :set_default_priority
  
    private
  
        def strip_title_and_category
            self.title = title.strip if title.present?
            self.category = category.strip if category.present?
        end

        def set_default_priority
            Rails.logger.info "Setting default priority. Current priority: #{self.priority.inspect}"
            self.priority = 3 if self.priority.blank? # 3 represents 'medium'
            Rails.logger.info "Priority after setting: #{self.priority.inspect}"
        end
  end
  