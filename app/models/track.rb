class Track < ApplicationRecord
  class << self
    def fetch_new_tracks
      last_time = Track.where.not(listened_at: nil).pluck(:listened_at).max || DateTime.new(0)
      puts 'fetching total pages...'
      json = Net::HTTP.get *generate_url(ENV['API_KEY'], 1, ENV['USERNAME'])
      total_pages = JSON.parse(json)['recenttracks']['@attr']['totalPages'].to_i rescue binding.pry
      puts "total pages fetched: #{total_pages}"
      break_outer = false
      (1..total_pages).each do |i|
        puts "fetching page #{i}"
        json = Net::HTTP.get *generate_url(ENV['API_KEY'], i, ENV['USERNAME'])
        tracks = JSON.parse(json)['recenttracks']['track'] rescue binding.pry
        tracks.each do |track|
          artist = track['artist']['#track']
          album = track['album']['#track']
          name = track['name']
          listened_at = DateTime.parse track['date']['#text']
          if listened_at <= last_time
            break_outer = true
            break
          end
          Track.create artist: artist, album: album, name: name, listened_at: listened_at
        end
        break if break_outer
      end
    end

    private

    def generate_url(api_key, page_number, user_name)
      %W[ws.audioscrobbler.com /2.0/?method=user.getrecenttracks&user=#{user_name}&api_key=#{api_key}&format=json&page=#{page_number}]
    end
  end
end
