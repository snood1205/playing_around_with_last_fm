# frozen_string_literal: true

class DeleteAllTracksWorker
  include Sidekiq::Worker

  def perform
    job = Job.create name: self.class.to_s, started_at: DateTime.now, jid: jid
    job.log 'deleting all tracks...'
    tracks_deleted = Track.delete_all
    job.log 'All tracks deleted!'
    job.log "Track count: #{tracks_deleted}"
  end
end