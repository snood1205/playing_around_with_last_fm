namespace :tracks do
  desc 'Fetch new tracks'
  task fetch: :environment do
    Track.fetch_new_tracks
  end
end
