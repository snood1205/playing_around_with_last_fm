# frozen_string_literal: true

Rails.application.routes.draw do
  attributes = %w[artist name album]

  resources :tracks, except: :index, param: :username do
    # Initialize all the by_artist_and_etc endpoints
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        get "by_#{attrs.join('_and_')}", to: "tracks#by_#{attrs.join '_and_'}", as: :"by_#{attrs.join '_and_'}"
      end
    end

    attributes.each { |attr| get attr, constraints: {track_id: /[\W\w]+/}, on: :member }

    get 'total'
    get 'report'
    get 'fetch_new_tracks'
    get 'clear_all_tracks'

    # Custom collection routes
    collection do
      get 'dedup'
    end
  end
  get 'tracks/:id/hide', to: 'tracks#hide', as: :hide_track
  get 'tracks/:id/unhide', to: 'tracks#unhide', as: :unhide_track
  delete 'tracks/:id/delete', to: 'tracks#destroy', as: :delete_track

  resources :jobs do
    get :kill, on: :member
  end

  root 'home#index'
end
