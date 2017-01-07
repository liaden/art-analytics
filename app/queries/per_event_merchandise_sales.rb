class PerEventMerchandiseSales
  def initialize(event_tag_filter: nil, merchandise_tag_filter: nil, artwork_tag_filter: nil)
    @event_tag_filter = event_tag_filter
    @merchandise_tag_filter = merchandise_tag_filter
    @artwork_tag_fitler = artwork_tag_filter
  end

  def total_revenue
    transform_money(Sale.joins(:event).group(:full_name).sum(:sale_price_cents))
  end

  def total_sold_items
    MerchandiseSale.joins(sale: :event).group(:full_name).sum(:quantity)
  end

  def total_customers
    Sale.joins(:event).group(:full_name).count
  end

  def revenue_per_day
    transform_money(transform_keys(Sale.joins(:event).group(:full_name).group_by_day_of_week(:sold_on).sum(:sale_price_cents)))
  end

  def sold_items_per_day
    transform_keys(MerchandiseSale.joins(sale: :event).group(:full_name).group_by_day_of_week(:sold_on).sum(:quantity))
  end

  def customers_per_day
    transform_keys(Sale.joins(:event).group(:full_name).group_by_day_of_week(:sold_on).count)
  end

  def run(grouping, metric)
    totals = 'total_' if grouping.to_s == 'total'
    per_day = '_per_day' if grouping.to_s == 'per_day'

    middle = metric if metric.to_s.in?(%w[sold_items revenue customers])

    qm = "#{totals}#{middle}#{per_day}"
    return [] unless self.respond_to?(qm)

    self.send(qm)
  end

  private

  def transform_money(data)
    data.transform_values! do |cents|
      Money.new(cents).dollars.to_s
    end
  end

  def transform_keys(data)
    days = [:mon, :tues, :wed, :thurs, :fri, :sat, :sun ]
    data.transform_keys! do |full_name, indexed_day_of_week|
      [full_name, days[indexed_day_of_week]]
    end
  end
end
