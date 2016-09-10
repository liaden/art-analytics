Rails.application.routes.draw do
  resources :events, only: [ :index, :create, :new]

  resource :control_panel, only: [ :index ]

  root to: 'control_panel#index'
end