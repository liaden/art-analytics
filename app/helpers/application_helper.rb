# frozen_string_literal: true

module ApplicationHelper
  def navbar_activity_class(nav_item)
    if controller.class.name.downcase.match?(nav_item.downcase)
      'nav-item active'
    else
      'nav-item'
    end
  end

  # TODO: this should go in simple_form as a component, probably
  def sf_tooltip_hash(placement: 'right', text: nil, i18n: nil)
    tooltip_text =
      if i18n
        I18n.t("simple_form.hints.#{i18n}")
      else
        text
      end

    {
      hint: false,
      label_html: {
        data:  {
          toggle:    'tooltip',
          placement: placement,
        },
        title: tooltip_text,
      },
    }
  end
end
