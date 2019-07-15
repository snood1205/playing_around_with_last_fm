# frozen_string_literal: true

class Track < ApplicationRecord
  validates :name, presence: true

  class << self
    def fetch_new_tracks(job = nil)
      last_time = Track.where.not(listened_at: nil).pluck(:listened_at).max || DateTime.new(0)
      total_pages = fetch_total_pages job
      puts_or_log "total pages fetched: #{total_pages}", job
      (1..total_pages).each do |page_number|
        tracks = fetch_tracks page_number, job
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
      artist = track_hash['artist']['#text']
      album = track_hash['album']['#text']
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

    def fetch_total_pages(job, retry_count = 0)
      puts_or_log 'fetching total pages...', job
      json = Net::HTTP.get(*generate_url(ENV['API_KEY'], 1, ENV['USERNAME']))
      begin
        JSON.parse(json)['recenttracks']['@attr']['totalPages'].to_i
      rescue NoMethodError
        puts_or_log "\n== Error Fetching Pages ==", job, :error
        puts_or_log json, job, :error
        puts_or_log 'Quiting now...', job, :error
        exit 1
      rescue JSON::ParserError
        puts_or_log "fetch retry number #{retry_count + 1}", job
        return fetch_total_pages job, retry_count + 1 if retry_count < 5

        raise FetchError, 'unable to fetch number of total pages'
      end
    end

    def fetch_tracks(page_number, job, retry_count = 0)
      puts_or_log "fetching page #{page_number}", job
      json = Net::HTTP.get(*generate_url(ENV['API_KEY'], page_number, ENV['USERNAME']))
      begin
        JSON.parse(json)['recenttracks']['track']
      rescue JSON::ParserError, NoMethodError
        puts_or_log "fetch retry number #{retry_count + 1}", job
        return fetch_tracks page_number, job, retry_count + 1 if retry_count < 5

        raise FetchError, "unable to fetch page number #{page_number}"
      end
    end

    def generate_url(api_key, page_number, user_name)
      %W[
        ws.audioscrobbler.com
        /2.0/?method=user.getrecenttracks&user=#{user_name}\&api_key=#{api_key}&format=json&page=#{page_number}
      ]
    end

    def puts_or_log(log, job, severity = :info)
      if job.nil?
        puts log
      else
        job.log log, severity
      end
    end
  end
end
