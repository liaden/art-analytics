# frozen_string_literal: true

class EventsController < ApplicationController
  def index
    @events = Event.all
    @event  = Event.new(started_at: Date.today, duration: 1)
  end

  def new
    @event = Event.new(started_at: Date.today, duration: 1)
  end

  def create
    params[:event][:ended_at]   = ended_at
    params[:event][:started_at] = started_at_date

    params[:event][:tags] = TagifyCleaner.process(params[:event][:tags])

    @event = Event.new(event_params)

    if @event.save
      redirect_to new_event_import_sale_path(@event)
    else
      render 'new'
    end
  end

  def show
    @event = Event.includes(merchandises: :artwork).find(params[:id])

    set_art_and_merch_names

    @art_merch_to_sold_count = merchandises.map do |merch|
      [[merch.name, merch.artworks_name], sold_count_by_merchandise_id[merch.id]]
    end.to_h

    @merch_quantities =
      merchandises.map { |m| ["#{m.artworks_name} #{m.name}", sold_count_by_merchandise_id[m.id]] }

    @totals_by_merch_type = MerchandiseSale
      .joins(:sale)
      .where(sales: { event_id: params[:id] })
      .joins(:merchandise)
      .group('merchandises.name')
      .sum('quantity')

    @totals_by_day = MerchandiseSale.joins(:sale)
      .where(sales: { event_id: params[:id] })
      .group_by_day('sales.sold_at')
      .sum('merchandise_sales.quantity')

    # Not needed for views so do not leak them
    @sold_count_by_merchandise_id = @merchandises = nil
  end

  private

  def event_params
    params
      .require(:event)
      .permit(:name, :started_at, :ended_at, :duration, tags: [])
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

  def sold_count_by_merchandise_id
    @sold_count_by_merchandise_id ||= MerchandiseSale.joins(:sale)
      .where(sales: { event_id: params[:id] })
      .group(:merchandise_id)
      .sum('quantity')
  end

  def merchandises
    @merchandises ||= Merchandise.joins(:artwork)
      .where(id: sold_count_by_merchandise_id.keys)
      .select('merchandises.id,merchandises.name,artworks.name as artworks_name')
  end

  def set_art_and_merch_names
    if params[:slim].present?
      @merchandise_names = merchandises.map(&:name).uniq
      @artwork_names     = merchandises.map { |merch| merch.artworks_name }.uniq
    else
      @merchandise_names = @event.merchandises.map(&:name).uniq
      @artwork_names     = @event.merchandises.map { |m| m.artwork.name }.uniq
    end
  end
end
