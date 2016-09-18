require 'rails_helper'

describe EventsController do
  render_views

  describe '#new' do
    it 'renders' do
      get :new
      expect(response.status).to eq 200
    end
  end

  describe '#create' do
    context 'without a duration' do
      it 'ended_at == started_at' do
        post :create, event: attributes_for(:event)

        event = Event.last
        expect(event.ended_at).to eq event.started_at
      end
    end

    context 'with a duration' do
      it 'computes ended_at' do
        attributes = attributes_for(:event).merge(duration: 7)

        post :create, event: attributes

        event = Event.last
        expect(event.ended_at).to eq attributes[:started_at] + 7.days
      end
    end

    context 'invalid data' do
      let(:attributes) do
        attrs = FactoryGirl.attributes_for(:event)
        attrs.delete(:name)
        { event: attrs }
      end

      it 'renders event form' do
        post :create, event: attributes

        expect(response.body).to include('New Event')
      end

      it 'does not save to database' do
        expect{post :create, attributes}.to_not change{Event.count}
      end
    end

    context 'valid data' do
      it 'redirects to import sales' do
        post :create, event: attributes_for(:event)

        expect(response).to redirect_to(new_import_sale_path)
      end

      it 'saves event to database' do
        expect{post :create, event: attributes_for(:event)}.to change{Event.count}.by(1)
      end
    end
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
