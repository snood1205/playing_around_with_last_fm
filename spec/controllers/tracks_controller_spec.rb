# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TracksController, type: :controller do
  context '#index' do
    before do
      @track_count = rand 1..100
      @track_count.times { create :track }
      get :index, format: :json
      @json = JSON.parse response.body
      @first_track = @json.first
    end

    it 'should return the appropriate number of tracks with appropriate attributes' do
      expect(@json.size).to eq @track_count
      expect(@first_track).to have_key 'artist'
      expect(@first_track).to have_key 'album'
      expect(@first_track).to have_key 'listened_at'
      expect(@first_track).to have_key 'name'
    rescue JSON::ParserError
      File.write 'response.html', response.body
    end
  end

  context '#action_missing' do
    attributes = %w[artist name album]
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        @action = "by_#{attrs.join '_and_'}"
        context @action do
          before do
            rand(1..100).times { create :track }
            get @action.to_sym, format: :json
            @first_track = @json.first
          end

          it 'should return the appropriate attributes' do
            attrs.each do |attr|
              expect(@first_track).to have_key attr
            end
          end
        end
      end
    end
  end
end
