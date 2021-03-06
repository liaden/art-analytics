# frozen_string_literal: true

FactoryBot.define do
  factory :merchandise_sale do
    merchandise { create(:merchandise) }
    sale { create(:sale) }
  end
end
