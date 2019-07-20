class AddHiddenFieldToTracks < ActiveRecord::Migration[5.2]
  def change
    add_column :tracks, :hidden, :boolean, default: false, null: false
  end
end
