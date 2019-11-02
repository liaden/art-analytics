# frozen_string_literal: true

FactoryBot.define do
  factory :merchandise do
    name    { 'canvas_print' }
    tags    { ['12x18', 'canvas'] }
    artwork { create(:artwork) }

    trait :with_sale do
      after(:create) do
        sales { [create(:sale)] }
      end
    end
  end

  factory :unknown_merchandise, class: Merchandise do
    artwork { create(:artwork) }
    unknown_item { true }
    name { '' }
  end
end
