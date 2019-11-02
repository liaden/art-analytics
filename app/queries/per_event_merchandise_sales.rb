# frozen_string_literal: true

class PerEventMerchandiseSales
  def initialize(options)
    @options = options
  end

  def total_revenue
    raw_data = Sale.joins(:event)
      .where(within_date)
      .where(event_tags)
      .group(:full_name, ordering).order(ordering)
      .sum(:sale_price_cents)

    simplify_total_keys(transform_money(raw_data))
  end

  def total_sold_items
    raw_data = MerchandiseSale.joins(sale: :event)
      .where(within_date)
      .group(:full_name, ordering)
      .order(ordering)
      .sum(:quantity)

    simplify_total_keys(raw_data)
  end

  def total_customers
    raw_data = Sale.joins(:event)
      .where(within_date)
      .group(:full_name, ordering)
      .order(ordering)
      .count

    simplify_total_keys(raw_data)
  end

  def revenue_per_day
    raw_data = Sale.joins(:event)
      .where(within_date)
      .group(:full_name)
      .group_by_day_of_week(:sold_at)
      .sum(:sale_price_cents)

    transform_money(transform_day_keys(raw_data))
  end

  def sold_items_per_day
    raw_data = MerchandiseSale.joins(sale: :event)
      .where(within_date)
      .group(:full_name)
      .group_by_day_of_week(:sold_at)
      .sum(:quantity)

    transform_day_keys(raw_data)
  end

  def customers_per_day
    raw_data = Sale.joins(:event)
      .where(within_date)
      .group(:full_name)
      .group_by_day_of_week(:sold_at)
      .count

    transform_day_keys(raw_data)
  end

  def run
    return [] unless @options.valid?

    totals  = 'total_' if grouping.to_s == 'total'
    per_day = '_per_day' if grouping.to_s == 'per_day'

    qm = "#{totals}#{metric}#{per_day}"

    self.send(qm)
  end

  private

  def transform_money(data)
    data.transform_values! do |cents|
      Money.new(cents).dollars.to_s
    end
  end

  def transform_day_keys(data)
    days = [:sun, :mon, :tues, :wed, :thurs, :fri, :sat]
    data.transform_keys! do |full_name, indexed_day_of_week|
      [full_name, days[indexed_day_of_week]]
    end
  end

  def simplify_total_keys(data)
    data.transform_keys! do |event_full_name, _ordering_item|
      event_full_name
    end
  end

  def ordering
    if options.ordering == 'name'
      'events.name'
    elsif options.ordering == 'date'
      'events.started_at'
    else
      'events.id'
    end
  end

  def event_tags
    { event: Event.tagged_with(@options.event_tag_filter.try(:tags)) }
  end

  def within_date
    { events: { started_at: @options.within_date } }
  end

  delegate :grouping, :metric, :date_after, :date_before,
           to: :options

  attr_reader :options
end
