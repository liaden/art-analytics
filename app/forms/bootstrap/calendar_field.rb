# frozen_string_literal: true

class Bootstrap::CalendarField < Bootstrap::Base
  def render(method, options = {})
    data = {
      class: 'datepicker-input',
      value: date_string(method),
      label: { hidden: true }
    }

    label = options.delete(:label) || {}
    label[:label_icon] = options.delete(:label_icon)

    @builder.group do
      @builder.label(method, label) +
      @builder.input_group(class: 'date flatpickr') do
        @template.concat @builder.text_field(method, data.merge!(options))
        @template.concat div_button
      end
    end
  end

  private

  def date_string(method)
    @builder.object.send(method).try(:strftime, '%Y-%m-%d')
  end

  def div_button
    tag_attrs = {
      class: 'input-group-append'
    }

    @template.content_tag(:div, tag_attrs) do
      @template.concat span_table
    end
  end

  def span_table
    @template.content_tag(:div, class: 'input-group-text') do
      @template.concat calendar_button
    end
  end

  def calendar_button
    tag_attrs = {
      class: 'input-button flatpickr-toggle'
    }

    @template.content_tag('a', tag_attrs) do
      calendar_icon
    end
  end

  def calendar_icon
    "<i class='fas fa-calendar'></i>".html_safe
  end
end

