# frozen_string_literal: true

class Bootstrap::ToggleCollectionField < Bootstrap::Base
  def initialize(builder, template)
    @builder  = builder
    @template = template
  end

  def render(method, collection, options = {})
    @builder.group do
      @builder.label(method, options) +
      @template.content_tag(:div, class: button_group_classes, data: { toggle: 'buttons' }) do
        @template.concat all_buttons(method, collection)
      end
    end
  end

  private

  def all_buttons(method, collection)
    collection.map do |value|
      label_text = human_attribute_name(method, value)

      button_group(method, value) do
        @template.concat(@builder.radio_button(method, value) + label_text)
      end
    end.join.html_safe
  end

  def toggle_label_classes(value, attribute_value)
    "btn btn-secondary #{'active' if value.to_s == attribute_value.to_s}"
  end

  def button_group(method, value, &block)
    css = "btn btn-secondary #{'active' if value.to_s == object.send(method).to_s}"

    @template.content_tag(:label, class: css, &block)
  end

  def button_group_classes
    classes = []
    classes << "btn-group#{'-vertical' if @vertical}"
    classes << 'btn-group-toggle'
    classes << 'btn-group-sm'
    classes << 'w-100'
    classes.join(' ')
  end
end
