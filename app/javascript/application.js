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
      const url = this.dataset.url
      
      fetch(url, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        credentials: 'same-origin'
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
        return response.json()
      })
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
        alert('Error updating task status. Please try again.')
      })
    })
  })

  // Handle inline editing
  document.querySelectorAll('.editable-field').forEach(function(field) {
    const display = field.querySelector('span[role="button"]')
    const popup = field.querySelector('.edit-popup')
    const input = popup.querySelector('select, input')

    // Show popup on click
    display.addEventListener('click', function(e) {
      e.stopPropagation()
      // Hide all other popups
      document.querySelectorAll('.edit-popup').forEach(p => {
        if (p !== popup) p.style.display = 'none'
      })
      popup.style.display = popup.style.display === 'none' ? 'block' : 'none'
      if (popup.style.display === 'block') {
        input.focus()
      }
    })

    // Handle input change
    input.addEventListener('change', function() {
      const url = this.dataset.url
      const field = this.dataset.field
      const value = this.value

      const data = {}
      data[field] = value

      fetch(url, {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({ task: data }),
        credentials: 'same-origin'
      })
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok')
        return response.json()
      })
      .then(data => {
        if (data.success) {
          location.reload() // Refresh to show updated data
        } else {
          alert('Error updating task: ' + data.message)
        }
      })
      .catch(error => {
        console.error('Error:', error)
        alert('Error updating task. Please try again.')
      })

      popup.style.display = 'none'
    })
  })

  // Close popups when clicking outside
  document.addEventListener('click', function(e) {
    if (!e.target.closest('.editable-field')) {
      document.querySelectorAll('.edit-popup').forEach(popup => {
        popup.style.display = 'none'
      })
    }
  })

  // Handle modal form submission
  const taskModal = document.getElementById('newTaskModal')
  if (taskModal) {
    const modal = new bootstrap.Modal(taskModal)
    const form = taskModal.querySelector('form')

    form.addEventListener('submit', function(e) {
      if (!form.checkValidity()) {
        e.preventDefault()
        e.stopPropagation()
      }
      form.classList.add('was-validated')
    })

    // Reset form when modal is hidden
    taskModal.addEventListener('hidden.bs.modal', function () {
      form.reset()
      form.classList.remove('was-validated')
    })

    // Close modal on successful submission
    document.addEventListener('turbo:submit-end', function(event) {
      if (event.detail.success) {
        modal.hide()
      }
    })
  }
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
