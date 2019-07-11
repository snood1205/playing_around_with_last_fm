json.array! @tracks do |track|
  track_info = track.first.is_a?(Array) ? track.first : [track.first]
  @action.zip(track_info).each do |k, v|
    json.set! k, v
  end
  json.count track.last
end
