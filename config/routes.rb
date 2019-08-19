# frozen_string_literal: true

Rails.application.routes.draw do
  resources :events, only: [:index, :create, :new, :show] do
    resources :import_sales, only: [:new, :create]
    resources :confirm_import_sales, only: [:create]
  end

  resources :events_charts, only: [:new, :create]
  resources :paired_artworks, only: [:new, :create]

  resources :tags, only: [:index]

  resource :control_panel, only: [:index]

  root to: 'control_panel#index'
end
