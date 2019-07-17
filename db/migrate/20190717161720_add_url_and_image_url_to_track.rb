# frozen_string_literal: true

class AddUrlAndImageUrlToTrack < ActiveRecord::Migration[5.2]
  def change
    change_table :tracks, bulk: true do |t|
      t.string :url
      t.string :image_url
    end
  end
end
