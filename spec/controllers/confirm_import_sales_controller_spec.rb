require 'rails_helper'

describe ConfirmImportSalesController do
  def import_data(file = 'testdata')
    File.read("spec/support/sales_sheets/#{file}.csv")
  end

  let(:event) { create(:event) }
  let(:import) { create(:import, import_file_data: import_data, event: event) }

  it 'saves the data' do
    expect {
      expect {
        expect {
          post :create, event_id: event.id, import_id: import.id
        }.to change{MerchandiseSale.count}.by(29)
      }.to change{Artwork.count}.by(5)
    }.to change{Merchandise.count}.by(9)
  end
end
