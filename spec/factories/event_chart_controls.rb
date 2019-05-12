# frozen_string_literal: true

FactoryBot.define do
  factory :event_chart_controls do
    # by default, use a wide range in tests to avoid missing data
    date_after { 1.year.ago }
    date_before { 1.year.from_now }

    grouping :per_day
    ordering :name
    metric :sold_items
  end
end
