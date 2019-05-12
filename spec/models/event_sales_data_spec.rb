# frozen_string_literal: true

describe EventSalesData do
  describe '.load' do
    it 'identifies SalesSpreadsheet' do
      expect(SalesSpreadsheet).to receive(:load)

      EventSalesData.load('spec/support/sales_sheets/testdata.csv')
    end

    it 'identifies SquareSpreadsheet' do
      expect(SquareSpreadsheet).to receive(:load)

      EventSalesData.load('spec/support/square_sheets/ohayocon.csv')
    end
  end
end
