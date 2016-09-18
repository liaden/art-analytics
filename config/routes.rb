Rails.application.routes.draw do
  resources :events, only: [ :index, :create, :new]
  resources :import_sales, only: [:new, :create]
  resource :control_panel, only: [ :index ]

  root to: 'control_panel#index'
end