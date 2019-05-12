# frozen_string_literal: true

require 'rails_helper'

describe ConfirmImportSalesController do
  def import_data(file)
    File.read("spec/support/#{file}.csv")
  end

  let(:event) { create(:event) }

  def import(file='sales_sheets/testdata')
    @import ||= create(:import, import_file_data: import_data(file), event: event)
  end

  context 'integration test:' do
    context 'custom sheet' do
      it 'works with testdata.csv' do
        expect {
          expect {
            expect {
              post :create, params: { event_id: event.id, import_id: import.id }
            }.to change{ MerchandiseSale.count }.by(29)
          }.to change{ Artwork.count }.by(5)
        }.to change{ Merchandise.count }.by(14)

        expect(Merchandise.where(unknown_item: true).where.not(artwork_id: nil).count).to eq 5
      end
    end

    context 'square' do
      let(:event) { create(:event, started_at: Date.new(2017, 1, 13), ended_at: Date.new(2017, 1, 15)) }

      it "works with ohayocon.csv" do
        expect {
          post :create, params: { event_id: event.id, import_id: import('square_sheets/ohayocon').id }
        }.to change{ Sale.count }.by(49) # 52 rows - 1 header - 1 refund -  1 refunded sale

        expect(Sale.where(event_id: event.id).sum(:sale_price_cents)).to eq 114500
        expect(Merchandise.where(unknown_item: true).joins(merchandise_sales: :sale).sum(:sale_price_cents)).to eq 16500
      end
    end
  end
end
