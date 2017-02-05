require 'rails_helper'

describe EventInventoryItem do
  it 'is unique by event_id and merchandise_id' do
    item = create(:event_inventory_item)

    expect {
      EventInventoryItem.create!(event_id: item.event_id, merchandise_id: item.merchandise_id)
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'must be associated with known item' do
    item = build(:event_inventory_item, merchandise: create(:unknown_merchandise))
    expect(item).to_not be_valid
  end
end
