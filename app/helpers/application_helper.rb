# frozen_string_literal: true

module ApplicationHelper
  def navbar_activity_class(nav_item)
    if controller.class.name.downcase.match?(nav_item.downcase)
      'nav-item active'
    else
      'nav-item'
    end
  end
end
