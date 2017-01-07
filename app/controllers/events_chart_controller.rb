class EventsChartController < ApplicationController
  def new
    @controls = { grouping: :total, metric: :revenue }

    @data = PerEventMerchandiseSales.new.total_revenue
    gon.push(data: serialize_event_stream(@data))

    render :new
  end

  def create
    @controls = { grouping: params[:grouping].to_sym, metric: params[:metric].to_sym }
    query = PerEventMerchandiseSales.new

    data = query.run(params[:grouping], params[:metric])
    @chart_data = if params[:grouping] == 'per_day'
                    serialize_per_day_streams(data)
                  else
                    serialize_event_stream(data)
                  end

    gon.push(data: @chart_data)

    render :edit
  end

  def update
    render :edit
  end

  private

  def serialize_per_day_streams(data)
    grouped = data.group_by { |item| item.first.shift }

    grouped.map do |event, daily_data|
      {
        key: event,
        values: daily_data.map do |label, value|
          { label: label.first, value: value }
        end
      }
    end
  end

  def serialize_event_stream(data)
    [{
      key: params[:metric],
      values: data.map { |event, value| { label: event, value: value } }
    }]
  end
end
