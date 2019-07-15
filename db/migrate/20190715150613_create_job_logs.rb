# frozen_string_literal: true

class CreateJobLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :job_logs do |t|
      t.string :log
      t.integer :severity

      t.belongs_to :job

      t.timestamps
    end
  end
end
