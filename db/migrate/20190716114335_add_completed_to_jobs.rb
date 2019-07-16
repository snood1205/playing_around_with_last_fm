class AddCompletedToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :completed, :boolean
  end
end
