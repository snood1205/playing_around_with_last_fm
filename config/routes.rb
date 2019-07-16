# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tracks, except: :show
  resource :tracks do
    # Initialize all the by_artist_and_etc endpoints
    attributes = %w[artist name album]
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        get :"by_#{attrs.join '_and_'}"
      end
    end

    get :fetch_new_tracks
  end

  resources :jobs
  resource :jobs

  root 'tracks#index'
end
