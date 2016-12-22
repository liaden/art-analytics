FactoryGirl.define do
  factory :event do
    sequence( :name){ |n| "event_#{n}" }

    started_at { Date.today.friday }
    ended_at { Date.today.friday + 2.days}

    tags ""

    trait :last_year do
      started_at { 1.year.ago.to_date.friday }
      ended_at { 1.year.ago.to_date.friday + 2.days }
    end
  end
end
