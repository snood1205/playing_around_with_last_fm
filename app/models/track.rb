# frozen_string_literal: true

class Track < ApplicationRecord
  validates :name, presence: true

  class << self
    def fetch_new_tracks
      last_time = Track.where.not(listened_at: nil).pluck(:listened_at).max || DateTime.new(0)
      total_pages = fetch_total_pages
      puts "total pages fetched: #{total_pages}"
      (1..total_pages).each do |page_number|
        tracks = fetch_tracks page_number
        break if process_tracks(tracks, last_time) == 'done'
      end
    end

    private

    def process_tracks(tracks, last_time)
      tracks.each do |track|
        was_already_inserted = create_track track, last_time
        return 'done' if was_already_inserted
      end
    end

    def create_track(track_hash, last_time)
      artist = track_hash['artist']['#track']
      album = track_hash['album']['#track']
      name = track_hash['name']
      if track_hash.key? 'date'
        listened_at = DateTime.parse track_hash['date']['#text']
      else
        # This might be _slightly_ inaccurate, but if the listened_at provided from last.fm is nil
        # then it means the song is currently being listened to. Alternatively, we could potentially
        # decide to not store these or store as nil. The issue with storing these with nil is if the
        # song is currently playing but does not hit the scrobble threshold (it is set variably from 50%-100% of
        # the track) then it could end up storing a track that was not actually scrobbled. Potentially
        # a method should be devised in the future to prevent this error.
        listened_at = DateTime.now
      end
      was_already_inserted = listened_at <= last_time
      Track.create artist: artist, album: album, name: name, listened_at: listened_at unless was_already_inserted
      was_already_inserted
    end

    def fetch_total_pages(retry_count = 0)
      puts 'fetching total pages...'
      json = Net::HTTP.get(*generate_url(ENV['API_KEY'], 1, ENV['USERNAME']))
      begin
        JSON.parse(json)['recenttracks']['@attr']['totalPages'].to_i
      rescue NoMethodError
        warn "\n== Error Fetching Pages =="
        warn json
        warn 'Quiting now...'
        exit 1
      rescue JSON::ParserError
        puts "fetch retry number #{retry_count + 1}"
        return fetch_total_pages retry_count + 1 if retry_count < 5

        raise FetchError, 'unable to fetch number of total pages'
      end
    end

    def fetch_tracks(page_number, retry_count = 0)
      puts "fetching page #{page_number}"
      json = Net::HTTP.get(*generate_url(ENV['API_KEY'], page_number, ENV['USERNAME']))
      begin
        JSON.parse(json)['recenttracks']['track']
      rescue JSON::ParserError
        puts "fetch retry number #{retry_count + 1}"
        return fetch_tracks page_number, retry_count + 1 if retry_count < 5

        raise FetchError, "unable to fetch page number #{page_number}"
      end
    end

    def generate_url(api_key, page_number, user_name)
      %W[
        ws.audioscrobbler.com
        /2.0/?method=user.getrecenttracks&user=#{user_name}\&api_key=#{api_key}&format=json&page=#{page_number}
      ]
    end
  end
end
