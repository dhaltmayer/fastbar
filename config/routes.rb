Fastbar::Application.routes.draw do
  resources :transactions

  root "welcome#index"

  resources :users
end
