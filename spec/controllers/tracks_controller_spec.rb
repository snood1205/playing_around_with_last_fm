# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TracksController, type: :controller do
  xcontext '#index' do
    before do
      @track_count = rand 1..100
      @track_count.times { create :track }
    end

    it 'should return the appropriate number of tracks with appropriate attributes' do
      get :index, format: :json
      json = JSON.parse response.body
      first_track = json.first
      expect(json.size).to eq @track_count
      expect(first_track).to have_key 'artist'
      expect(first_track).to have_key 'album'
      expect(first_track).to have_key 'listened_at'
      expect(first_track).to have_key 'name'
    rescue JSON::ParserError
      # Test should fail on rescue
      expect(false).to be_truthy
      File.write 'response_index.html', response.body
    end
  end

  xcontext '#action_missing' do
    attributes = %w[artist name album]
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        action = "by_#{attrs.join '_and_'}"
        context action do
          before do
            rand(1..100).times { create :track }
          end

          it 'should return the appropriate attributes' do
            get action.to_sym, format: :json
            json = JSON.parse response.body
            @first_track = json.first
            attrs.each do |attr|
              expect(@first_track).to have_key attr
            end
          rescue JSON::ParserError
            # Test should fail on rescue
            expect(false).to be_truthy
            File.write "response_#{action}.html", response.body
          end
        end
      end
    end
  end
end
