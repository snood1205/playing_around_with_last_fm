# frozen_string_literal: true

class CreateStatus < ActiveRecord::Migration[5.2]
  def change
    create_table :status do |t|
      t.boolean :importing, default: false, null: false

      t.timestamps
    end
  end
end
