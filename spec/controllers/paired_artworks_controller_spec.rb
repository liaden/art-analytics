# frozen_string_literal: true

require 'rails_helper'

describe PairedArtworksController do
  render_views

  describe '#new' do
    it 'is successful' do
      get :new
    end
  end

  describe '#create' do
    it 'is successful' do
      post :create, params: { artwork_pairing_controls: attributes_for(:artwork_pairing_controls) }
    end
  end
end
