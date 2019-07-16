# frozen_string_literal: true

class AddDefaultValueToCompletedOnJobs < ActiveRecord::Migration[5.2]
  def change
    change_column :jobs, :completed, :boolean, default: false
  end
end
