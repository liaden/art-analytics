require 'rails_helper'

describe EventsChartController do
  render_views

  describe '#new' do
    it 'renders the view' do
      get :new
    end
  end

  describe '#create' do
    it 'renders the view' do
      post :create, params: { grouping: :per_day, metric: :revenue }
    end
  end
end
