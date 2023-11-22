# frozen_string_literal: true

class AddCompletedToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :completed, :boolean, default: false, null: false
  end
end
