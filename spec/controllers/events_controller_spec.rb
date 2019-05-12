# frozen_string_literal: true

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
    let(:params) { { event: attributes_for(:event, ended_at: nil) } }

    context 'without a duration' do
      it 'ended_at == started_at' do
        post :create, params: params

        event = Event.last
        expect(event.ended_at).to eq event.started_at
      end
    end

    context 'with a duration' do
      it 'computes ended_at' do
        attributes = attributes_for(:event)

        post :create, params: params.merge!(duration: 7)

        event = Event.last
        expect(event.ended_at).to eq attributes[:started_at] + 6.days
      end
    end

    context 'invalid data' do
      before { params[:event].delete(:name) }

      it 'renders event form' do
        post :create, params: params

        expect(response.body).to include('New Event')
      end

      it 'does not save to database' do
        expect{ post :create, params: params }.to_not change{ Event.count }
      end
    end

    context 'valid data' do
      it 'redirects to import sales' do
        post :create, params: params

        expect(response.status).to eq 302
        expect(response.header["Location"]).to match(/import_sales\/new/)
      end

      it 'saves event to database' do
        expect{ post :create, params: params }.to change{ Event.count }.by(1)
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

  describe '#show' do
    subject(:page) do
      get :show, params: { id: event.id }
      response.body.downcase
    end

    let(:sale) { create(:sale, :with_event, :with_merchandise, quantity: 25) }
    let(:event) { sale.event }

    it "adds quantities for same merch across sales" do
      create(:sale, :with_merchandise, event: event, quantity: 411, sold_at: event.started_at)

      expect(page).to include('436')
    end

    context 'single sale' do
      it { is_expected.to include(event.name.downcase) }
      it { is_expected.to include(event.started_at.year.to_s) }

      it "includes merchandise name" do
        is_expected.to include(sale.merchandises.first.name)
      end

      it "includes quantity sold" do
        is_expected.to include(sale.merchandise_sales.first.quantity.to_s)
      end
    end
  end
end
