# frozen_string_literal: true

Rails.application.routes.draw do
  attributes = %w[artist name album]

  resource :tracks, except: :show do
    # Initialize all the by_artist_and_etc endpoints
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        get :"by_#{attrs.join '_and_'}"
      end
    end

    get :total
    get :report
    get :fetch_new_tracks
    get :clear_all_tracks
    get :dedup
  end
  resources :tracks, except: :show do
    attributes.each { |attr| get attr, constraints: {track_id: /[\W\w]+/} }
    get :hide
    get :unhide
  end

  resources :jobs do
    get :kill
  end
  resource :jobs

  root 'tracks#index'
end
