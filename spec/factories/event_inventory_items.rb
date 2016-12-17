FactoryGirl.define do
  factory :event_inventory_item do
    event { create(:event) }
    merchandise { create(:merchandise) }
  end
end
