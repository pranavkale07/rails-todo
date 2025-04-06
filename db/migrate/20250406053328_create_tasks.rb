class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :category
      t.integer :priority
      t.date :due_date
      t.time :due_time
      t.string :status, default: "pending"
      t.timestamps
    end
  end
end
