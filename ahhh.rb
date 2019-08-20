tracks = Track.all.group_by {|track| track.listened_at}.to_a.select do |track|
  track[1].length > 1
end
