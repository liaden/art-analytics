# frozen_string_literal: true

Rails.application.routes.draw do
  concern :taggable do |extra|
    resources :tags, except: :show, controller: :resource_tags, defaults: { format: :json }, **extra do
      delete '', on: :collection, action: :destroy_all
    end
  end

  resources :events, only: [:index, :create, :new, :show] do
    resources :import_sales, only: [:new, :create]
    resources :confirm_import_sales, only: [:create]

    concerns :taggable, resource: 'event'
  end

  resources :artworks do
    concerns :taggable, resource: 'artwork'
  end

  resources :merchandise do
    concerns :taggable, resource: 'merchandise'
  end

  resources :sales do
    concerns :taggable, resource: 'sale'
  end

  resources :tags, only: [:index, :show]
  scope ':resource' do
    resources :tags, as: :scoped_tags
  end

  resources :events_charts, only: [:new, :create]
  resources :paired_artworks, only: [:new, :create]

  resources :tags, only: [:index]

  resource :control_panel, only: [:index]

  root to: 'control_panel#index'
end
