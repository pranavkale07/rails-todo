module ApplicationHelper
  def priority_badge_class(priority)
    case priority
    when 1
      'bg-danger'
    when 2
      'bg-warning text-dark'
    when 3
      'bg-info text-dark'
    when 4
      'bg-primary'
    when 5
      'bg-secondary'
    else
      'bg-secondary'
    end
  end

  def status_badge_class(status)
    case status
    when 'pending'
      'bg-secondary'
    when 'in_progress'
      'bg-primary'
    when 'completed'
      'bg-success'
    when 'cancelled'
      'bg-danger'
    else
      'bg-secondary'
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    css_class = column == params[:sort] ? "current #{direction}" : nil
    link_to title, { sort: column, direction: direction, 
                    category: params[:category], 
                    priority: params[:priority], 
                    status: params[:status] }, 
            class: css_class
  end
end
