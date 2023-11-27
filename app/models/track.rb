# frozen_string_literal: true

require_relative '../errors'

# @!attribute name [rw]
#  @return [String] the name of the track.
# @!attribute artist [rw]
#  @return [String] the artist of the track.
# @!attribute album [rw]
#  @return [String] the name of the album of the track.
# @!attribute listened_at [rw]
#  @return [DateTime] the time at which the song was listened to (and scrobbled to last.fm).
class Track < ApplicationRecord
  validates :name, presence: true

  default_scope -> { order(listened_at: :desc).where(hidden: false) }
  scope :without_blank_album, -> { where.not(album: '') }
  scope :report, -> { unscoped.without_blank_album.where(hidden: false) }

  class << self
    # Fetches all new tracks from last.fm by using the API
    #
    # @param job [Job] the job to record logs to (can be nil and logs will just be output to stdout/stderr).
    def fetch_new_tracks(username, job = nil, **options)
      return if ENV['API_KEY'].nil?

      @track_count = 0
      Status.start_importing
      fetch_tracks_by_total_pages username, job, options
      @track_count
    ensure
      Status.end_importing
    end

    # Fetches all tracks from last.fm by using the API
    #
    # @param job [Job] the job to record logs to (can be nil and logs will just be output to stdout/stderr).
    def fetch_all_tracks(username, job = nil)
      @track_count = 0
      Status.start_importing
      total_pages = fetch_total_pages username, job
      puts_with_log "total pages fetched: #{total_pages}", job
      (1..total_pages).each do |page_number|
        fetch_and_process_tracks username, page_number, job
      end
      @track_count
    ensure
      Status.end_importing
    end

    def dedup_tracks
      tracks_to_dedup = all.group_by(&:listened_at).to_a.select do |track|
        track[1].length > 1
      end
      tracks_to_dedup.each do |_, tracks|
        tracks[1..].each(&:destroy)
      end
    end

    private

    # Processes track array (normally 50 tracks) and creates track based on information parsed out from
    # the JSON data retrieved from the API.
    #
    # @param tracks [Array<Hash>] an array of hashes of track information parsed out from the API.
    # @param last_time [DateTime] the most recent time listened to of any track in the database (or epoch if there are
    #  no songs with listened_at times in the database). Is used to check to not double-insert songs.
    # @return [Boolean] returns true if the job should be continued, false otherwise
    def process_tracks(tracks, last_time = nil)
      if last_time.nil?
        tracks.each { |track| create_track track } && true
      else
        tracks.all? { |track| create_track track, last_time }
      end
    end

    # Creates a track from the parsed hash.
    #
    # @param track_hash [Hash] the hash with the track information, the hash is more complex than presented but the
    #  relevant information for the hash schema is:
    #
    #     {
    #       'artist' => {
    #         '#text' => String
    #       },
    #       'album' => {
    #         '#text' => String
    #       },
    #       'image' => [
    #         {
    #             'size' => 'extralarge', # other sizes appear but we want to store the url for the extra large image.
    #             '#text' => String # this is the url
    #         }
    #       ]
    #       'date' => {
    #         'uts' => String # converted to int
    #       },
    #       'url' => String,
    #       'name' => String
    #     }
    #
    # @param last_time [DateTime] the most recent time listened to of any track in the database (or epoch if there are
    #  no songs with listened_at times in the database). Is used to check to not double-insert songs.
    # @return [Boolean] returns whether or not the tracks should continue being created. This is based on the
    #  listened_at check.
    def create_track(track_hash, last_time = nil)
      artist, album, image_url, name, url = parse_data_from_track_hash track_hash
      # After careful consideration, we can just wait to import the song that's currently playing until after it's
      # done playing. This isn't a serious issue and the solution before led to double insertions at times and incorrect
      # listened_at at times. This is a more conservative and "truthful" solution.
      return true unless track_hash.key? 'date'

      listened_at = Time.at(track_hash['date']['uts'].to_i).utc.to_datetime
      was_already_inserted = !last_time.nil? && listened_at <= last_time
      unless was_already_inserted
        @track_count += 1
        Track.create artist:, album:, name:, listened_at:, url:, image_url:
      end
      !was_already_inserted
    end

    # Fetches the total number of pages from the last.fm API.
    #
    # @param job [Job] the job to log to.
    # @param retry_count [Integer] the retry attempt number (defaults to 0).
    #
    # @return [Hash] the JSON converted to a Ruby hash.
    def fetch_total_pages(username, job, retry_count = 0)
      puts_with_log 'fetching total pages...', job
      json = Net::HTTP.get(*generate_url(ENV.fetch('API_KEY', nil), 1, username))
      begin
        JSON.parse(json)['recenttracks']['@attr']['totalPages'].to_i
      rescue JSON::ParserError, NoMethodError
        puts_with_log "fetch retry number #{retry_count + 1}", job, :warn
        return fetch_total_pages username, job, retry_count + 1 if retry_count < 4

        puts_with_log 'unable to fetch number of total pages', job, :error
        raise FetchError, 'unable to fetch number of total pages'
      end
    end

    # Fetch the tracks from the last.fm API.
    #
    # @param page_number [Integer] the page number to query. API results are paginated to 50 tracks per page.
    # @param job [Job] the job to log to.
    # @param retry_count [Integer] the retry attempt number (defaults to 0).
    #
    # @return [Array<Hash>] an array of hashes of the tracks.
    def fetch_tracks(page_number, job, username, retry_count = 0)
      puts_with_log "fetching page #{page_number}", job
      json = Net::HTTP.get(*generate_url(ENV.fetch('API_KEY', nil), page_number, username))
      begin
        JSON.parse(json)['recenttracks']['track']
      rescue JSON::ParserError, NoMethodError
        puts_with_log "fetch retry number #{retry_count + 1}", job, :warn
        return fetch_tracks page_number, job, username, retry_count + 1 if retry_count < 4

        raise FetchError, "unable to fetch page number #{page_number}"
      end
    end

    def fetch_and_process_tracks(username, page_number, job, last_time = nil)
      tracks = fetch_tracks username, page_number, job
      process_tracks tracks, last_time
    end

    # Provides an array to allow `Net::HTTP.get` to construct a URL.
    #
    # @param api_key [String] the api key being used to query last.fm. If you do not have an API key you can obtain one
    #  at https://www.last.fm/api/account/create.
    # @param page_number [Integer] the page number to request
    # @param username [String] the last.fm username whose scrobbles you want to fetch.
    #
    # @return [Array<String>] the array to construct the URL for `Net::HTTP.get`
    def generate_url(api_key, page_number, username)
      %W[
        ws.audioscrobbler.com
        /2.0/?method=user.getrecenttracks&user=#{username}&api_key=#{api_key}&format=json&page=#{page_number}
      ]
    end

    def parse_data_from_track_hash(track_hash)
      [track_hash['artist']['#text'],
       track_hash['album']['#text'],
       track_hash['image'].last['#text'],
       track_hash['name'],
       track_hash['url']]
    end

    def fetch_tracks_by_total_pages(username, job, options)
      last_time = Track.unscoped.where.not(listened_at: nil).pluck(:listened_at).max || DateTime.new(0)
      total_pages = options[:total_pages] || fetch_total_pages(username, job)
      puts_with_log "total pages fetched: #{total_pages}", job
      (1..total_pages).each do |page_number|
        break unless fetch_and_process_tracks page_number, job, last_time
      end
    end

    # If a job is provided, log both to the job and stdout/stderr, otherwise just logs to stdout/stderr.
    #
    # @param message [String] the text to be output and logged
    # @param job [Job] the job to which to log the message
    # @param severity [Symbol] the severity level for the message (can be :info, :warn, or :error). Defaults to `:info`.
    def puts_with_log(message, job, severity = :info)
      puts_method = {
        info: :puts,
        warn: :warn,
        error: :warn # cowardly using warn instead of raise to allow application to continue running.
      }[severity]
      job&.log message, severity
      send puts_method, message
    end
  end
end
