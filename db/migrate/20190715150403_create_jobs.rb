# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs_tables do |t|
      t.datetime :job_started
      t.string :job_name

      t.timestamps
    end
  end
end
