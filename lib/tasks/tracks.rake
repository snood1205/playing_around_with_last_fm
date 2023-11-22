# frozen_string_literal: true

require 'net/http'

namespace :tracks do
  desc 'Fetch new tracks'
  task fetch: :environment do
    FetchNewTracksWorker.new.perform
  end

  desc 'Fetch all tracks'
  task :fetch_all, %i[username] => :environment do |_, arg|
    raise 'Username is required' unless arg[:username]

    FetchAllTracksWorker.new.perform arg[:username]
  end

  desc 'Delete all tracks'
  task delete_all: :environment do
    DeleteAllTracksWorker.new.perform
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
    DedupTracksWorker.new.perform
  end
end
