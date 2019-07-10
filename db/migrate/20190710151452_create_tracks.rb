class CreateTracks < ActiveRecord::Migration[5.2]
  def change
    create_table :tracks do |t|
      t.string :artist
      t.string :album
      t.string :name
      t.datetime :listened_at

      t.timestamps
    end
  end
end
