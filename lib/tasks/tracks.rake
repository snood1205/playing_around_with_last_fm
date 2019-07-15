# frozen_string_literal: true

require 'net/http'

namespace :tracks do
  desc 'Fetch new tracks'
  task fetch: :environment do
    FetchNewTracksWorker.new.perform
  end

  desc 'Delete all tracks'
  task delete_all: :environment do
    Track.delete_all
  end

  desc 'Reset tracks'
  task reset: :environment do
    puts 'Deleting all tracks'
    Rake::Task['tracks:delete_all'].invoke '--verbose'
    puts 'Fetching all tracks'
    Rake::Task['tracks:fetch'].invoke '--verbose'
  end
end
