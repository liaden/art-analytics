FactoryGirl.define do
  factory :sale do
    sale_price 2500
    list_price 2500
    sold_on "2016-06-05"
    note "MyText"

    trait :with_merchandise do
      after(:build) do |sale|
        sale.merchandise_sales = create_list :merchandise_sale, 1, sale: sale
      end
    end

    trait :with_event do
      after(:create) do |sale|
        event { create(:event) }
      end
    end
  end
end
