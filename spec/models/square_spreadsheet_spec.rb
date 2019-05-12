# frozen_string_literal: true

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
      expect(data.first[:merchandise_sold].first).to eq({ artwork_name: 'Detonator', quantity: 2, merch_name: 'Small' })
    end

    it "parses all sold merchandises" do
      expect(data.first[:merchandise_sold].size).to eq 3
    end

    it "handles two small vs large print" do
      expect(data.last[:merchandise_sold]).to eq(
        [
          { artwork_name: 'Detonator', quantity: 1, merch_name: 'Large' },
          { artwork_name: 'Detonator', quantity: 1, merch_name: 'Small' },
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

  describe '#process' do
    let(:data) do
      {
        total:           1000,
        discounts:       0,
        tax:             100,
        processing_fees: 32,
        time_zone:       'Central Time (US & Canada)',
        time:            '23:00',
        date:            '1/15/2017',
        description:     sale_description,
      }
    end

    let(:sale_description) { '2 x art_name (merch_name)' }

    let(:spreadsheet) { SquareSpreadsheet.new(nil) }
    let(:result) { spreadsheet.process(data) }

    describe ':sold_at' do
      let(:sold_at) { result[:sold_at] }

      it 'stores time in UTC' do
        expect(sold_at.zone).to eq '+00:00'
      end

      it 'does not mangle date' do
        expect(sold_at.day).to eq 15
      end

      it 'does not mangle hour' do
        expect(sold_at.hour).to eq 23
      end
    end

    describe ':merchandise_sold' do
      let(:merch_sold) { result[:merchandise_sold].first }

      it 'has quantity' do
        expect(merch_sold[:quantity]).to eq 2
      end

      it 'has the artwork_name' do
        expect(merch_sold[:artwork_name]).to eq 'art_name'
      end

      it 'has merch_name' do
        expect(merch_sold[:merch_name]).to eq 'merch_name'
      end

      context 'unkown item' do
        let(:sale_description) { 'Custom Amount' }

        it 'has quantity 1' do
          expect(merch_sold[:quantity]).to eq 1
        end

        it 'has Unknown Artwork name' do
          expect(merch_sold[:artwork_name]).to eq Merchandise.unknown_artwork_item.name
        end

        it 'does not have merch_name' do
          expect(merch_sold[:merch_name]).to be_nil
        end
      end
    end

    describe '#parse_sale' do
      def run(merchandise)
        SquareSpreadsheet.load(minimal_csv).send(:parse_sale, merchandise)
      end

      it 'parses specified quantity'
      it 'parses custom amount as uknown artwork item'
      it 'parses merch name'
      it 'merges duplicate items' do
        result = run('Pilgrimage  (Small), A Fish May Love A Bird (Small), Pilgrimage  (Small)')

        expect(result).to include(
          { quantity: 2, artwork_name: 'Pilgrimage', merch_name: 'Small' },
          { quantity: 1, artwork_name: 'A Fish May Love A Bird', merch_name: 'Small' }
        )
      end
    end

    [:total, :discounts, :tax, :processing_fees].each do |field|
      it "parses :#{field} as Money" do
        expect(result[field]).to be_an_instance_of(Money)
      end
    end
  end
end
