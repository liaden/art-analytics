# frozen_string_literal: true

class TempusDominusInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    input_html_options[:class]   = 'form-control datepicker-input'
    input_html_options[:value] ||= object.send(attribute_name).try(:strftime, '%Y-%m-%d')

    input_group_div do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat div_button
    end
  end

  def div_button
    tag_attrs = {
      class: 'input-group-append'
    }

    template.content_tag(:div, tag_attrs) do
      template.concat span_table
    end
  end

  def span_table
    template.content_tag(:div, class: 'input-group-text') do
      template.concat calendar_button
    end
  end

  def calendar_button
    tag_attrs = {
      class: 'input-button flatpickr-toggle'
    }

    template.content_tag('a', tag_attrs) do
      calendar_icon
    end
  end

  def calendar_icon
    "<i class='fas fa-calendar'></i>".html_safe
  end

  def input_group_div
    tag_attrs = {
      class: 'input-group date flatpickr',
    }

    template.content_tag(:div, tag_attrs) do
      yield
    end
  end
end
