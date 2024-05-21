Rails.application.routes.draw do
  devise_for :users
  root 'films#index'
  get 'films/index'
end
