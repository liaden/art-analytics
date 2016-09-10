require 'rails_helper'

describe EventsController do
  render_views

  describe '#new' do

  end

  describe '#create' do

  end

  describe '#index' do
    context 'with no events yet' do
      it 'renders' do
        get :index
        expect(response.status).to eq 200
      end
    end

    context 'with events' do
      before { create(:event) }

      it 'renders' do
        get :index
        expect(response.status).to eq 200
      end
    end

  end
end
