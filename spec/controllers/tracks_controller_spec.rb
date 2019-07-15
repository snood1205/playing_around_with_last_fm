# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TracksController, type: :controller do
  context '#index' do
    before do
      @track_count = rand 1..100
      @track_count.times { create :track }
    end

    it 'should return the appropriate number of tracks with appropriate attributes' do
      get :index, format: :json
      @json = JSON.parse response.body
      expect(@json.size).to eq @track_count
      first_track = @json.first
      expect(first_track).to have_key 'artist'
      expect(first_track).to have_key 'album'
      expect(first_track).to have_key 'listened_at'
      expect(first_track).to have_key 'name'
    rescue JSON::ParserError
      File.write 'response.html', response.body
    end
  end
end
