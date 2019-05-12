# frozen_string_literal: true

describe MerchandiseSale do
  let(:merch) { create(:merchandise) }
  let(:sale) { create(:sale) }

  describe '#other_sold_items' do
    let(:merch_sold) { create(:sale, :with_merchandise).merchandise_sales.first }

    it 'is empty if sale of one item' do
      expect(merch_sold.other_sold_items).to be_empty
    end

    it 'excludes unrelated merchandise sales' do
      create(:sale, :with_merchandise)
      expect(merch_sold.other_sold_items).to be_empty
    end

    it 'excludes itself' do
      sale   = create(:sale, :with_merchandise, number_of_merch: 2)
      others = sale.merchandise_sales.first.other_sold_items
      expect(others).to eq [sale.merchandise_sales.second]
    end
  end

  describe '#quantity' do
    it 'defaults to 1 in rails' do
      merch_sale = MerchandiseSale.new(merchandise: merch, sale: sale)
      expect(merch_sale.quantity).to eq 1
    end

    it 'defaults to 1 in postgres' do
      ActiveRecord::Base.connection.execute(
        "insert into merchandise_sales (merchandise_id, sale_id) values (#{merch.id},#{sale.id})"
      )
      expect(MerchandiseSale.last.quantity).to eq 1
    end

    it 'cannot be 0' do
      merch_sale = build(:merchandise_sale, quantity: 0)
      expect(merch_sale).to be_invalid
    end

    it 'is valid without explicity quantity' do
      merch_sale = create(:merchandise_sale, quantity: nil)
      expect(merch_sale.errors).to be_empty
    end
  end
end
