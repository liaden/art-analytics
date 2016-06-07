FactoryGirl.define do
  factory :merchandise do
    name 'canvas_print'
    tags ['12x18', 'canvas']
    artwork { create(:artwork) }

    trait :with_sale do
      after(:create) do
        sales { [create(:sale)] }
      end
    end
  end
end