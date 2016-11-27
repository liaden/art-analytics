FactoryGirl.define do
  factory :sale do
    sale_price 2500
    list_price 2500
    sold_on "2016-06-05"
    note "MyText"

    trait :with_merchandise do
      transient do
        quantity 1
      end
      after(:build) do |sale, evaluator|
        sale.merchandise_sales = create_list :merchandise_sale, 1, sale: sale, quantity: evaluator.quantity
      end
    end

    trait :with_event do
      after(:build) do |sale|
        sale.event = create(:event)
        sale.sold_on = sale.event.started_at.to_date
      end
    end
  end
end
