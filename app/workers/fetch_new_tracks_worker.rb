# frozen_string_literal: true

require 'net/http'

class FetchNewTracksWorker
  include Sidekiq::Worker

  def perform
    job = Job.create(name: self.class.to_s, started_at: DateTime.now, jid:)
    track_count = Track.fetch_new_tracks job
    job.log 'Job completed!'
    job.log "Tracks inserted: #{track_count}"
    job.log 'Deduping tracks...'
    tracks_deduped = Track.dedup_tracks
    job.log 'Tracks deduped!'
    job.log "Duplicated tracks removed: #{tracks_deduped.count}"
    job.mark_as_completed
  end
end
