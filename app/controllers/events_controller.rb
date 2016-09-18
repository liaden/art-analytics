class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def new
    @event = Event.new
  end

  def create
    params[:event][:ended_at] = ended_at
    @event = Event.new(event_params)

    if @event.save
      redirect_to new_event_import_sale_path(@event)
    else
      render 'new'
    end
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
      params[:event][:started_at].to_date + duration.days
    end
  end
end
