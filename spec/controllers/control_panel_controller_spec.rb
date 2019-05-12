# frozen_string_literal: true

require 'rails_helper'

describe ControlPanelController do
  render_views

  context '#index' do
    it 'renders' do
      get :index
      expect(response.status).to eq 200
    end
  end
end
