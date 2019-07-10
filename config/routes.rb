Rails.application.routes.draw do
  resources :tracks, except: :show
  resource :tracks, except: :show
end
