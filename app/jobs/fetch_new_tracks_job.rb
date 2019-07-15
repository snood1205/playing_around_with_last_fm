# frozen_string_literal: true

class FetchNewTracksJob < ApplicationJob
  def perform
    job = Job.create name: self.class.to_s, started_at: DateTime.now
    Track.fetch_new_tracks job
  end
end