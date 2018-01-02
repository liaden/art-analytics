require 'rails_helper'

describe SquareSpreadsheet do
  let(:minimal_csv) { StringIO.new(File.read('spec/support/square_sheets/minimal.csv')) }
  let(:refund_csv) { StringIO.new(File.read('spec/support/square_sheets/refund.csv')) }
  let(:complex_csv) { StringIO.new(File.read('spec/support/square_sheets/complex.csv')) }

  describe 'converters' do
    let(:data) { SquareSpreadsheet.load(minimal_csv).sales_data }

    it 'parses US dollars' do
      expect(data.first[:discounts]).to be_an_instance_of(Money)
    end

    it 'snake cases headers' do
      expect(data.first[:time_zone]).to eq 'Central Time (US & Canada)'
    end

    it 'converts dates' do
      expect(data.first[:sold_at]).to be_an_instance_of(DateTime)
    end

    it 'parses date correctly' do
      expect(data.first[:sold_at].to_date).to eq(Date.new(2017, 1, 15))
    end
  end

  describe 'refunds' do
    let(:data) { SquareSpreadsheet.load(refund_csv).sales_data }

    it 'skips refund and original sale' do
      expect(data).to be_empty
    end
  end

  describe 'complex' do
    let(:data) { SquareSpreadsheet.load(complex_csv).sales_data }

    it "handles quantity of 2" do
      expect(data.first[:merchandise_sold].first).to eq({artwork_name: 'Detonator', quantity: 2, merch_name: 'Small'})
    end

    it "parses all sold merchandises" do
      expect(data.first[:merchandise_sold].size).to eq 3
    end

    it "handles two small vs large print" do
      expect(data.last[:merchandise_sold]).to eq(
        [
          {artwork_name: 'Detonator', quantity: 1, merch_name: 'Large'},
          {artwork_name: 'Detonator', quantity: 1, merch_name: 'Small'}
        ]
      )
    end
  end

  describe '.parse_artwork_name' do
    def run(text)
      SquareSpreadsheet.parse_artwork_name(text)
    end

    it 'ignores variant' do
      expect(run('Name (Large)')).to eq 'Name'
    end

    it 'handles no variants' do
      expect(run('Name')).to eq 'Name'
    end
  end

  describe '.parse_merchandise_name' do
    def run(text)
      SquareSpreadsheet.parse_merchandise_name(text)
    end

    it 'captures text inside of parens' do
      expect(run('(Large)')).to eq 'Large'
    end

    it 'discards trailing whitespace' do
      expect(run('(Large )')).to eq 'Large'
    end

    it 'captures multiple words' do
      expect(run('(16x24 Canvas)')).to eq '16x24 Canvas'
    end

    it 'discards everything before "("' do
      expect(run('2 x artwork name (Large)')).to eq 'Large'
    end

    it 'only captures last set of parens' do
      expect(run('artwork (1) (Large)')).to eq 'Large'
    end
   end
end
