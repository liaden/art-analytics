# frozen_string_literal: true

FactoryBot.define do
  factory :artwork do
    sequence(:name) { |n| "#{Faker::Book.title} (#{n})" }

    trait :with_merchandise do
      merchandises { [create(:merchandise)] }
    end
  end

  factory :unknown_artwork, class: Artwork do
    name { "doesn't matter" }

    after(:create) do |artwork|
      create(:unknown_merchandise, artwork: artwork)
    end
  end
end
