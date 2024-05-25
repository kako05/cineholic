Rails.application.routes.draw do
  devise_for :users

  root "films#index"

  resources :films do
    collection do
      get "showing", to: "films#showing", as: :showing_films
      get "search", to: "films#search", as: :search_films
    end
  end

  resources :users, only: [:show, :edit, :update]
end