Rails.application.routes.draw do
  devise_for :users
  root 'films#index'
  resources :films do
    collection do
      get "showing", to: "films#showing", as: :showing_films
      get "search", to: "films#search", as: :search_films
    end
    member do
      get "show_details", to: "films#show_details"
    end
  end
  get "films/search", to: "films#search", as: :search_films

  resources :users, only: [:show, :edit, :update]
end