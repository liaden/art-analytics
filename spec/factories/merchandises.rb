FactoryGirl.define do
  factory :merchandise do
    name 'canvas_print'
    tags ['12x18', 'canvas']
    artwork { create(:artwork) }

    trait :with_purchase do
      after(:create) do
        purchases { [create(:purchase)] }
      end
    end
  end
end