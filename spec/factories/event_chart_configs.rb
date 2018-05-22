FactoryBot.define do
  factory :event_chart_config do
    # by default, use a wisde range in tests to avoid missing data
    date_after { 1.year.ago }
    date_before { 1.year.from_now }

    grouping :per_day
    metric :sold_items

    sequence(:name) { |n| "chart-config-#{n}" }
  end
end
