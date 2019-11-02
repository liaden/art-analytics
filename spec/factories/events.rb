# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    sequence(:name){ |n| "event_#{n}" }

    started_at { Date.today.friday }

    tags { '' }

    # should only be used for controller via attributes_for
    trait :with_tagify_tags do
      tags { "[{\"value\":\"festival\"}]" }
    end

    after(:build) do |event, evaluator|
      if evaluator.ended_at.nil?
        event.ended_at = event.started_at + 2.days
      end
    end

    trait :last_year do
      started_at { 1.year.ago.to_date.friday }
      ended_at   { 1.year.ago.to_date.friday + 2.days }
    end

    trait :with_complex_sales do
      after(:create) do |event, evaluator|
        sale         = create(:sale, :with_merchandise)
        event.sales += [
          sale,
          create(:sale, :with_merchandise, sale_price: 5),
          create(:sale, :with_merchandise, event: event, day_n: 1),
          create(:sale, :with_merchandise, number_of_merch: 2),
        ]
        event.sales << create(:sale, of_merchandise: sale.merchandises.first, quantity: 2)
      end
    end

    trait :with_sale do
      transient do
        day_n { nil }
      end

      after(:create) do |event, evaluator|
        event.sales << create(:sale, :with_merchandise, day_n: evaluator.day_n)
      end
    end

    trait :with_sale_of_many do
      after(:create) do |event, evaluator|
        event.sales << create(:sale, :with_merchandise, number_of_merch: 3)
      end
    end

    trait :with_huge_price do
      after(:create) do |event, evaluator|
        event.sales << create(:sale, :with_merchandise, sale_price: 12345)
      end
    end
  end
end
