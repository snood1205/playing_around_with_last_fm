# frozen_string_literal: true

require 'net/http'

namespace :tracks do
  desc 'Fetch new tracks'
  task fetch: :environment do
    FetchNewTracksJob.perform_now
  end

  desc 'Delete all tracks'
  task delete_all: :environment do
    Track.delete_all
  end

  desc 'Reset tracks'
  task reset: :environment do
    Rake::Task['tracks:delete_all'].invoke
    Rake::Task['tracks:fetch'].invoke
  end
end
