# frozen_string_literal: true

class AddUsernameToTracks < ActiveRecord::Migration[7.1]
  def change
    add_column :tracks, :username, :string
  end
end
