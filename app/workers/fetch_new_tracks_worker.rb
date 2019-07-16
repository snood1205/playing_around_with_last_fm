# frozen_string_literal: true

require 'net/http'

class FetchNewTracksWorker
  include Sidekiq::Worker

  def perform
    job = Job.create name: self.class.to_s, started_at: DateTime.now, jid: jid
    track_count = Track.fetch_new_tracks job
    job.log 'Job completed!'
    job.log "Tracks inserted: #{track_count}"
  end
end
