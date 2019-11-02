# frozen_string_literal: true

class EventChartControls
  include ActiveModel::Model
  include Virtus.model

  GROUPING_OPTIONS = [
    :per_day,
    :total,
  ].freeze

  ORDERING_OPTIONS = [
    :name,
    :date,
  ].freeze

  METRIC_OPTIONS = [
    :revenue,
    :sold_items,
    :customers,
  ].freeze

  attribute :grouping,    Symbol, default: GROUPING_OPTIONS.first
  attribute :ordering,    Symbol, default: ORDERING_OPTIONS.first
  attribute :metric,      Symbol, default: METRIC_OPTIONS.first
  attribute :date_after,  Date
  attribute :date_before, Date

  attribute :event_tag_filter,       TagFilter
  attribute :merchandise_tag_filter, TagFilter

  validates :grouping, inclusion: { in: GROUPING_OPTIONS }
  validates :ordering, inclusion: { in: ORDERING_OPTIONS }, if: :ordering_applicable?
  validates :metric, inclusion: { in: METRIC_OPTIONS }

  # validates :name, presence: true

  def initialize(params = {})
    if params.key?(:event_tag_filter)
      params[:event_tag_filter] = { tags: params[:event_tag_filter] }
    end

    if params.key?(:merchandise_tag_filter)
      params[:merchandise_tag_filter] = { tags: params[:merchandise_tag_filter] }
    end

    super(params)
  end

  def per_day?
    grouping == :per_day
  end

  def ordering_applicable?
    grouping == :total
  end

  def within_date
    (date_after.to_date)..(date_before.to_date)
  end
end
