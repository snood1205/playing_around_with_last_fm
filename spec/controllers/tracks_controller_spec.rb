# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TracksController do
  describe '#action_missing' do
    attributes = %w[artist name album]
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        action = "by_#{attrs.join '_and_'}"
        context action do
          before do
            rand(1..100).times { create(:track) }
          end

          it 'returns the appropriate attributes' do
            get action.to_sym, format: :json
            json = response.parsed_body
            first_track = json.first
            attrs.each { |attr| expect(first_track).to have_key attr }
          end
        end
      end
    end
  end
end
