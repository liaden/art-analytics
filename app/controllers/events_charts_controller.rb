# frozen_string_literal: true

class EventsChartsController < ApplicationController
  def new
    @controls = EventChartControls.new(
      grouping: :total, ordering: :date, metric: :revenue, date_before: DateTime.now, date_after: 2.year.ago
    )
    data = PerEventMerchandiseSales.new(@controls).run
    gon.push(data: serialize_event_stream(data))

    render :new
  end

  def create
    @controls = EventChartControls.new(chart_params)
    if @controls.valid?
      send_data_to_gon(@controls)
    end
    render :edit
  end

  private

  def send_data_to_gon(controls)
    query = PerEventMerchandiseSales.new(controls)
    data  = query.run()

    @chart_data =
      if controls.per_day?
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
        key:    event,
        values: daily_data.map do |label, value|
          { label: label.first, value: value }
        end,
      }
    end
  end

  def serialize_event_stream(data)
    [
      {
        key:    params[:metric],
        values: data.map { |event, value| { label: event, value: value } },
      },
    ]
  end

  def chart_params
    params
      .require(:event_chart_controls)
      .permit(:grouping, :ordering, :metric, :date_after, :date_before)
  end
end
