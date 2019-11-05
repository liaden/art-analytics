# frozen_string_literal: true

require 'rails_helper'

describe PairedArtworksController do
  render_views

  describe '#new' do
    it 'is successful' do
      get :new
      expect(response).to be_successful
    end
  end

  describe '#create' do
    let(:attrs) { attributes_for(:artwork_pairing_controls) }

    it 'is successful' do
      post :create, params: { artwork_pairing_controls: attrs }
      expect(response).to be_successful
    end

    context '"" for date_after and date_before' do
      before { attrs.merge!(date_after: '', date_before: '') }
    end

    it 'handles "" for dates' do
      post :create, params: { artwork_pairing_controls: attrs }
      expect(response).to be_successful
    end
  end
end
