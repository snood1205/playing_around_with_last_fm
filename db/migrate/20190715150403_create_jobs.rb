# frozen_string_literal: true

class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.datetime :started_at
      t.string :name
      t.string :jid

      t.timestamps
    end
  end
end
