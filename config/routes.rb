Rails.application.routes.draw do
  devise_for :users
  root 'films#index'
  resources :films do
    member do
      get "showing", to: "films#showing", as: :showing_film
    end
  end
  get "films/search", to: "films#search", as: :search_films
  resources :users, only: [:show, :edit, :update]
end