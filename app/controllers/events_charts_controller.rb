class EventsChartsController < ApplicationController
  def new
    @controls = EventChartConfig.new(
      grouping: :total, metric: :revenue, date_before: DateTime.now, date_after: 1.year.ago
    )

    data = PerEventMerchandiseSales.new(@controls).run
    gon.push(data: serialize_event_stream(data))

    render :new
  end

  def create
    @controls = EventChartConfig.create!(chart_params)
    send_data_to_gon
    render :edit
  end

  def update
    @controls = EventChartConfig.find(params[:id])
    send_data_to_gon
    render :edit
  end

  private

  def send_data_to_gon
    query = PerEventMerchandiseSales.new(@controls)
    @controls.update!(chart_params)

    data = query.run()
    @chart_data = if @controls.per_day?
                    serialize_per_day_streams(data)
                  else
                    serialize_event_stream(data)
                  end

    gon.push(data: @chart_data)
  end

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


  def chart_params
    params
      .require(:event_chart_config)
      .permit(:grouping, :metric, :date_after, :date_before)
  end
end
