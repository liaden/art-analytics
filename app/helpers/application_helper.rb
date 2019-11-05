# frozen_string_literal: true

module ApplicationHelper
  ActionView::Base.default_form_builder = BootstrapFormBuilder

  # bypass BootstrapFormBuilder to Rails default
  def rails_form_for(object, options = {}, &block)
    options = { builder: RailsFormBuilder }.merge(options)
    form_for(object, options, &block)
  end

  def rails_form_with(object, options = {}, &block)
    options = { builder: RailsFormBuilder }.merge(options)
    form_with(object, options, &block)
  end

  def navbar_activity_class(nav_item)
    active_map = {
      EventsChartsController   => 'chart',
      PairedArtworksController => 'chart',
      EventsController         => 'event',
      TagsController           => 'tag',
    }

    active_class = ' active' if active_map[controller.class] == nav_item.downcase

    "nav-item#{active_class}"
  end

  def date_range(range)
    "#{range.first.strftime('%b %d, %Y')} - #{range.last.strftime('%b %d, %Y')}"
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
