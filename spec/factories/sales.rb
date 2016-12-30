FactoryGirl.define do
  factory :sale do
    sale_price 2500
    list_price 2500
    sold_on { Date.today.friday }
    note "MyText"

    event

    transient do
      quantity 1
      day_n nil
      of_merchandise nil
    end

    trait :with_merchandise do
      transient { number_of_merch 1 }

      after(:build) do |sale, evaluator|
        sale.merchandise_sales = create_list :merchandise_sale, evaluator.number_of_merch, sale: sale, quantity: evaluator.quantity

        if evaluator.number_of_merch > 1
          sale.note = "Created merchandise sale #{evaluator.number_of_merch}"
        end
      end
    end

    trait :with_event do
      after(:build) do |sale|
        sale.event = create(:event)
        sale.sold_on = sale.event.started_at.to_date
      end
    end

    after(:build) do |sale, evaluator|
      if sale.event.present? and evaluator.day_n.present?
        sale.sold_on = sale.event.started_at + evaluator.day_n.days
      end

      if evaluator.of_merchandise.present?
        sale.merchandise_sales << create(:merchandise_sale, sale: sale, quantity: evaluator.quantity, merchandise: evaluator.of_merchandise)
      end
    end
  end
end
