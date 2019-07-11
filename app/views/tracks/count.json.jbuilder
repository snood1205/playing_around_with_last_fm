json.array! @tracks do |track|
  @action.zip(track.first).each do |k, v|
    json.set! k, v
  end
  json.count track.last
end
