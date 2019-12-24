module Helpable
  def h
    ApplicationController.helpers
  end

  def routes
    Rails.application.routes.url_helpers
  end
end
