require 'rails_helper'

describe ImportSalesController do
  render_views

  let!(:event) { create(:event, ended_at: 2.days.from_now) }

  def datafile(file = 'testdata')
    Rack::Test::UploadedFile.new("spec/support/sales_sheets/#{file}.csv")
  end

  describe '#new' do
    it 'is nested under an event' do
      get :new, event_id: event.id
      expect(response.status).to eq 200
    end
  end

  describe '#create' do
    context 'on failure' do
      it 'renders new form' do
        post :create, event_id: event.id, spreadsheet: datafile('invalid')
        expect(response.body).to include('spreadsheet')
      end

      it 'reports error in spreadsheet' do
        post :create, event_id: event.id, spreadsheet: datafile('invalid')
        expect(response.body).to include('sold on')
      end
    end

    context 'dry run' do
      describe 'page' do
        subject do
          post :create, event_id: event.id, spreadsheet: datafile
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
          post :create, event_id: event.id, spreadsheet: datafile
        }.to_not change{MerchandiseSale.count}
      end
    end

    context 'success' do
      it 'redirects to event path' do
        post :create, event_id: event.id, spreadsheet: datafile, confirmed: true
        expect(response).to redirect_to(events_path(event))
      end
    end
  end
end
