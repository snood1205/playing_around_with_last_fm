# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tracks, except: :show
  resource :tracks do
    attributes = %w[artist name album]
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        get :"by_#{attrs.join '_and_'}"
      end
    end
  end

  root 'tracks#by_artist_and_album_and_name'
end
