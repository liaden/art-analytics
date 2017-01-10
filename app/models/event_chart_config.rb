class EventChartConfig < ApplicationRecord
  GROUPING_OPTIONS = %w[per_day total]
  METRIC_OPTIONS = %w[revenue sold_items customers]

  validates :grouping, inclusion: { in: GROUPING_OPTIONS }
  validates :metric, inclusion: { in: METRIC_OPTIONS }

  #validates :name, presence: true

  def per_day?
    grouping == 'per_day'
  end

  def within_date
    date_after..date_before
  end
end
