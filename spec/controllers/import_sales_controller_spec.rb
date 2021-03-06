# frozen_string_literal: true

require 'rails_helper'

describe ImportSalesController do
  render_views

  # before { Merchandise.create_unknown_for(nil) }
  let!(:event) { create(:event) }

  def datafile(file='testdata')
    Rack::Test::UploadedFile.new("spec/support/sales_sheets/#{file}.csv")
  end

  describe '#new' do
    it 'is nested under an event' do
      get :new, params: { event_id: event.id }
      expect(response.status).to eq 200
    end
  end

  describe '#create' do
    context 'on failure' do
      it 'renders new form' do
        post :create, params: { event_id: event.id, spreadsheet: datafile('invalid') }
        expect(response.body).to include('spreadsheet')
      end

      it 'reports error in spreadsheet' do
        post :create, params: { event_id: event.id, spreadsheet: datafile('invalid') }
        expect(response.body).to include('sold on')
      end
    end

    context 'dry run' do
      describe 'page' do
        subject do
          post :create, params: { event_id: event.id, spreadsheet: datafile }
          response.body.downcase
        end

        it 'shows new merchandise count' do
          is_expected.to include('new merchandise (9 items)')
        end

        it 'shows new artworks' do
          is_expected.to include('artwork1')
        end

        it 'shows new artworks count' do
          is_expected.to include('new artworks (5 items)')
        end

        it 'shows new merchandise' do
          is_expected.to include('8x8')
        end

        it 'include confirm button' do
          is_expected.to include('confirm')
        end

        it 'includes import_id' do
          is_expected.to include('import_id')
        end

        it 'includes inventory list' do
          is_expected.to include('artwork1 8x10')
        end
      end

      it 'does not create new merchandise sales' do
        expect {
          post :create, params: { event_id: event.id, spreadsheet: datafile }
        }.to_not change{ MerchandiseSale.count }
      end
    end

    context 'success' do
      it 'redirects to event path' do
        post :create, params: { event_id: event.id, spreadsheet: datafile, confirmed: true }
        expect(response).to redirect_to(events_path(event))
      end
    end

    context 'square import' do
      let(:square_sheet) do
        Rack::Test::UploadedFile.new("spec/support/square_sheets/ohayocon.csv")
      end

      let(:event) { create(:event, started_at: Date.new(2017, 1, 13), ended_at: Date.new(2017, 1, 15)) }

      it 'works' do
        post :create, params: { event_id: event.id, spreadsheet: square_sheet, confirmed: true }
      end
    end
  end
end
