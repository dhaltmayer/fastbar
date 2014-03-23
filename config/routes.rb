Fastbar::Application.routes.draw do
  resources :transactions

  root "welcome#index"

  resources :users

  post 'api_transaction', to: 'transactions#pos_create'

  get 'api_getuser', to: 'users#api_barcode'
end
