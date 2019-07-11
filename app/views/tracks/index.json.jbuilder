json.array! Track.find_each do |track|
  json.name track.name
  json.artist track.artist
  json.album track.album
  json.listened_at track.listened_at
end
