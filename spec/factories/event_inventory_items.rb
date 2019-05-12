# frozen_string_literal: true

FactoryBot.define do
  factory :event_inventory_item do
    event { create(:event) }
    merchandise { create(:merchandise) }
  end
end
