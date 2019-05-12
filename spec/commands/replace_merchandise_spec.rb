# frozen_string_literal: true

describe ReplaceMerchandise do
  let(:replacee) { create(:merchandise) }
  let(:replacer) { create(:merchandise) }

  let!(:params) do
    { replacee: replacee, replacer: replacer }
  end

  describe 'validations' do
    after { expect{ ReplaceMerchandise.run!(params) }.to raise_error(Mutations::ValidationException) }

    it 'requires replacee' do
      params.delete(:replacee)
    end

    it 'requires replacer' do
      params.delete(:replacer)
    end
  end

  describe '#run' do
    it 'updates merchandise sales' do
      create(:merchandise_sale, merchandise: replacee)

      expect {
        ReplaceMerchandise.run!(params)
      }.to change{ MerchandiseSale.count }.by(0)

      expect(replacer.reload.merchandise_sales.size).to eq 1
    end

    it 'updates event inventory items' do
      create(:event_inventory_item, merchandise: replacee)

      expect {
        ReplaceMerchandise.run!(params)
      }.to change{ EventInventoryItem.count }.by(0)

      expect(replacer.reload.event_inventory_items.size).to eq 1
    end

    it 'destroys replacee' do
      ReplaceMerchandise.run!(params)
      expect(replacee).to be_destroyed
    end

    it 'destroys event inventory item collisions' do
      replacee_inventory_item = create(:event_inventory_item, merchandise: replacee)
      create(:event_inventory_item, merchandise: replacer, event: replacee_inventory_item.event)

      ReplaceMerchandise.run!(params)

      expect(EventInventoryItem.where(id: replacee_inventory_item.id)).to be_empty
    end

    it 'migrates dimension if replacee has one and replacer does not' do
      dimension          = create(:dimension)
      replacee.dimension = dimension
      ReplaceMerchandise.run!(params)
      expect(replacer.dimension.id).to eq dimension.id
    end
  end
end
