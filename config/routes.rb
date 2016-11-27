Rails.application.routes.draw do
  resources :events, only: [ :index, :create, :new, :show] do
    resources :import_sales, only: [:new, :create]
    resources :confirm_import_sales, only: [:create]
  end

  resource :control_panel, only: [:index]

  root to: 'control_panel#index'
end
