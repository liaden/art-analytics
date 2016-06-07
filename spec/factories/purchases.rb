FactoryGirl.define do
  factory :sale do
    sale_price 2500
    list_price 2500
    sold_on "2016-06-05"
    note "MyText"
    merchandises { [create(:merchandise)] }

    trait :with_event do
      after(:create) do
        event { create(:event) }
      end
    end
  end
end
