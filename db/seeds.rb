# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'

tracks = CSV.read 'snood1205.csv'
tracks.each do |artist, album, name, listened_at|
  listened_at = DateTime.parse listened_at unless listened_at.nil?
  Track.create artist: artist, album: album, name: name, listened_at: listened_at
end
