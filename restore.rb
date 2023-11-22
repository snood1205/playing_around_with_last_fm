# frozen_string_literal: true

tracks = JSON.parse File.read 'tracks.json'
tracks.each do |track|
  Track.create(%w[artist album name listened_at url image_url].index_with { |i| track[i] })
end
