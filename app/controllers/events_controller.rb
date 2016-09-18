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
      redirect_to new_import_sale_path
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
      # params[:event][:duration] being nil and converting to 0 is intentional
      params[:event][:started_at].to_date + (params[:event][:duration].to_i).days
    end
  end
end
