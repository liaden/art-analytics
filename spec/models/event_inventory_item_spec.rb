require 'rails_helper'

describe EventInventoryItem do
  it 'is unique by event_id and merchandise_id' do
    create(:event_inventory_item)

    expect {
      create(:event_inventory_item)
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
