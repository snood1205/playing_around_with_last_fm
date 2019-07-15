# frozen_string_literal: true

class FetchNewTracksWorker
  include Sidekiq::Worker

  def perform
    job = Job.create name: self.class.to_s, started_at: DateTime.now, jid: jid
    Track.fetch_new_tracks job
  end
end
