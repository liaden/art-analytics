# frozen_string_literal: true

class EventDecorator < BaseDecorator
  def name
    @object.name
  end

  def time_period
    "#{@object.started_at} - #{@object.ended_at}"
  end
end
