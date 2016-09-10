module ApplicationHelper
  def navbar_activity_class(nav_item)
    if controller.class.name.downcase.match(nav_item.downcase)
      'active'
    else
      ''
    end
  end
end
