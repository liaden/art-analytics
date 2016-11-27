class EventDecorator
  include Haml::Helpers

  def initialize(event)
    @event = event
  end

  def name
    @event.name
  end

  def time_period
    "#{@event.started_at} - #{@event.ended_at}"
  end
end
