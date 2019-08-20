# frozen_string_literal: true

require 'net/http'

namespace :tracks do
  desc 'Fetch new tracks'
  task fetch: :environment do
    FetchNewTracksWorker.perform_async
  end

  desc 'Delete all tracks'
  task delete_all: :environment do
    DeleteAllTracksWorker.perform_async
  end

  desc 'Reset tracks'
  task reset: :environment do
    puts 'Deleting all tracks'
    Rake::Task['tracks:delete_all'].invoke '--verbose'
    puts 'Fetching all tracks'
    Rake::Task['tracks:fetch'].invoke '--verbose'
  end

  desc 'Dedup tracks'
  task dedup: :environment do
    DedupTracksWorker.perform_async
  end
end
