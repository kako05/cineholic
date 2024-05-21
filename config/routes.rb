Rails.application.routes.draw do
  root 'films#index'
  get 'films/index'
end
