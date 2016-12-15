class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def new
    @event = Event.new
  end

  def create
    params[:event][:ended_at] = ended_at
    params[:event][:started_at] = started_at_date

    @event = Event.new(event_params)

    if @event.save
      redirect_to new_event_import_sale_path(@event)
    else
      render 'new'
    end
  end

  def show
    @event = EventDecorator.new(Event.find(params[:id]))

    sold_count_by_merchandise_id = MerchandiseSale.
      joins(:sale).
      where(sales: { event_id: params[:id] }).
      group(:merchandise_id).
      sum('quantity')

    merchandises = Merchandise.
      joins(:artwork).
      where(id: sold_count_by_merchandise_id.keys).
      select('merchandises.id,merchandises.name,artworks.name as artworks_name')

    @merchandise_names = merchandises.map(&:name).uniq
    @artwork_names = merchandises.map { |merch| merch.artworks_name }.uniq

    @art_merch_to_sold_count = merchandises.map do |merch|
      [[merch.name, merch.artworks_name], sold_count_by_merchandise_id[merch.id]]
    end.to_h

    gon.merch_quantities = merchandises.map do |merch|
      { name: "#{merch.artworks_name} #{merch.name}", value: sold_count_by_merchandise_id[merch.id] }
    end

    gon.totals_by_merch_type = MerchandiseSale.
      joins(:sale).
      where(sales: { event_id: params[:id] }).
      joins(:merchandise).
      group('merchandises.name').
      sum('quantity').
      map { |k,v| {name: k, value: v} }
  end

  private

  def event_params
    params
      .require(:event)
      .permit(:name, :started_at, :ended_at, :tags)
  end

  def ended_at
    if params[:event][:started_at]
      # include start day in the duration when computing ended_at
      duration = [params[:duration].to_i - 1, 0].max
      started_at_date + duration.days
    end
  end

  def started_at_date
    params[:event][:started_at].to_date
  rescue ArgumentError
    Date.strptime(params[:event][:started_at], '%m/%d/%Y')
  end
end
