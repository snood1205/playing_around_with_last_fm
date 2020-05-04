# frozen_string_literal: true

json.array! @tracks do |track|
  json.name track.name
  json.artist track.artist
  json.album track.album
  json.listenedAt track.listened_at.iso8601(3)
  json.lastFmUrl track.url
end
