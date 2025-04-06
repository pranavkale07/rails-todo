// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', function() {
  // Initialize tooltips
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipTriggerList.forEach(function (tooltipTriggerEl) {
    new bootstrap.Tooltip(tooltipTriggerEl)
  })

  // Handle task completion checkboxes
  document.querySelectorAll('.task-complete-checkbox').forEach(function(checkbox) {
    checkbox.addEventListener('change', function() {
      const taskId = this.dataset.taskId
      const url = this.dataset.url
      
      fetch(url, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Content-Type': 'application/json'
        }
      })
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          // Update the status badge
          const row = checkbox.closest('tr')
          const statusCell = row.querySelector('td:nth-child(5)') // Status is in the 5th column
          const statusBadge = statusCell.querySelector('.badge')
          statusBadge.textContent = data.new_status.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
          statusBadge.className = `badge ${status_badge_class(data.new_status)}`
        } else {
          // Revert checkbox if there was an error
          checkbox.checked = !checkbox.checked
          alert('Error updating task: ' + data.message)
        }
      })
      .catch(error => {
        console.error('Error:', error)
        checkbox.checked = !checkbox.checked
        alert('Error updating task status')
      })
    })
  })

  // Helper function to get status badge class
  function status_badge_class(status) {
    switch (status) {
      case 'completed':
        return 'bg-success'
      case 'in_progress':
        return 'bg-primary'
      case 'cancelled':
        return 'bg-danger'
      case 'pending':
      default:
        return 'bg-secondary'
    }
  }
})
