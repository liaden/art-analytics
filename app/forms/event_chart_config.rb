class EventChartConfig
  include Virtus.model
  include ActiveModel::Model

  GROUPING_OPTIONS = %w[per_day total]
  ORDERING_OPTIONS = %w[name date metric_value]
  METRIC_OPTIONS = %w[revenue sold_items customers]

  attribute :grouping,    String
  attribute :ordering,    String
  attribute :metric,      String
  attribute :date_after,  Date
  attribute :date_before, Date

  validates :grouping, inclusion: { in: GROUPING_OPTIONS }
  validates :ordering, inclusion: { in: ORDERING_OPTIONS }, if: :ordering_applicable?
  validates :metric, inclusion: { in: METRIC_OPTIONS }

  #validates :name, presence: true

  def per_day?
    grouping == 'per_day'
  end

  def ordering_applicable?
    grouping == 'total'
  end

  def within_date
    date_after..date_before
  end
end
