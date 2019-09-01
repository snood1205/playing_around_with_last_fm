# frozen_string_literal: true

class DedupTracksWorker
  include Sidekiq::Worker

  def perform
    job = Job.create name: self.class.to_s, started_at: DateTime.now, jid: jid
    job.log 'deduping tracks...'
    tracks_deduped = Track.dedup_tracks
    job.log 'Tracks deduped!'
    job.log "Duplicated tracks removed: #{tracks_deduped.count}"
    job.mark_as_completed
  end
end
