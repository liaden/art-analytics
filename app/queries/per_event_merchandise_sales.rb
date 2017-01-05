class PerEventMerchandiseSales
  def initialize(event_tag_filter: nil, merchandise_tag_filter: nil, artwork_tag_filter: nil)
    @event_tag_filter = event_tag_filter
    @merchandise_tag_filter = merchandise_tag_filter
    @artwork_tag_fitler = artwork_tag_filter
  end

  def total_revenue
    Sale.joins(:event).group(:full_name).sum('sales.sale_price')
  end

  def total_sold_items
    MerchandiseSale.joins(sale: :event).group(:full_name).sum('quantity')
  end

  def total_customers
    Sale.joins(:event).group(:full_name).count
  end

  def revenue_per_day
    transform_keys(Sale.joins(:event).group(:full_name).group_by_day_of_week(:sold_on).sum(:sale_price))
  end

  def sold_items_per_day
    transform_keys(MerchandiseSale.joins(sale: :event).group(:full_name).group_by_day_of_week(:sold_on).sum(:quantity))
  end

  def customers_per_day
    transform_keys(Sale.joins(:event).group(:full_name).group_by_day_of_week(:sold_on).count)
  end

  private

  def transform_keys(data)
    days = [:mon, :tues, :wed, :thurs, :fri, :sat, :sun ]
    data.transform_keys! do |full_name, indexed_day_of_week|
      [full_name, days[indexed_day_of_week]]
    end
  end
end
