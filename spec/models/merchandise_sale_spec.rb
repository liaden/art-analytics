describe MerchandiseSale do
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
      sale = create(:sale, :with_merchandise, number_of_merch: 2)
      others = sale.merchandise_sales.first.other_sold_items
      expect(others).to eq [sale.merchandise_sales.second]
    end
  end
end
