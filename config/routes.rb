# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tracks
  resource :tracks, except: :show do
    attributes = %w[artist name album]
    (1..attributes.size).each do |size|
      attributes.permutation(size).each do |attrs|
        get :"by_#{attrs.join '_and_'}"
      end
    end
  end
end
