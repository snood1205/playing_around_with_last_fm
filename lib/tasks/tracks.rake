# frozen_string_literal: true

namespace :tracks do
  desc 'Fetch new tracks'
  task fetch: :environment do
    FetchNewTracksJob.perform_now
  end
end
