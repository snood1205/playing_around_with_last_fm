# frozen_string_literal: true

Rails.application.routes.draw do
  attributes = %w[artist name album]

  resources :tracks, except: :show, param: :username do
    # Initialize all the by_artist_and_etc endpoints
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        get "tracks/by_#{attrs.join('_and_')}", to: "tracks#by_#{attrs.join '_and_'}", as: :"by_#{attrs.join '_and_'}"
      end
    end
    get 'tracks/:track_username', to: 'tracks#index', as: :by_username, constraints: {track_username: /[\W\w]+/}

    attributes.each { |attr| get attr, constraints: {track_id: /[\W\w]+/}, on: :member }

    # Custom collection routes
    collection do
      get 'total'
      get 'report'
      get 'fetch_new_tracks'
      get 'clear_all_tracks'
      get 'dedup'
    end
  end
  get 'tracks/:id/hide', to: 'tracks#hide', as: :hide_track
  get 'tracks/:id/unhide', to: 'tracks#unhide', as: :unhide_track
  delete 'tracks/:id/delete', to: 'tracks#destroy', as: :delete_track

  resources :jobs do
    get :kill, on: :member
  end

  root 'tracks#index'
end
