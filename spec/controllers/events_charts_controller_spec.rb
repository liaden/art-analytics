require 'rails_helper'

describe EventsChartsController do
  render_views

  describe '#new' do
    it 'renders the view' do
      get :new
    end
  end

  describe '#create' do
    it 'renders the view' do
      post :create, params:
        { event_chart_config: attributes_for(:event_chart_config) }
    end
  end
end
