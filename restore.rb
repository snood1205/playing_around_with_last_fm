tracks = JSON.parse File.read 'load.json'
tracks.each do |track|
  Track.create %w[artist album name listened_at url image_url].map {|i| [i, track[i]]}.to_h
end
