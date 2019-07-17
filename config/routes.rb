# frozen_string_literal: true

Rails.application.routes.draw do
  attributes = %w[artist name album]

  resources :tracks, except: :show do
    attributes.each { |attr| get attr }
  end
  resource :tracks do
    # Initialize all the by_artist_and_etc endpoints
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        get :"by_#{attrs.join '_and_'}"
      end
    end

    get :report
    get :fetch_new_tracks
  end

  resources :jobs do
    get :kill
  end
  resource :jobs

  root 'tracks#index'
end
