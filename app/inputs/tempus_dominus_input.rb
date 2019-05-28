# frozen_string_literal: true

class TempusDominusInput < SimpleForm::Inputs::Base
  def input(_wrapper_options)
    input_html_options[:class]   = 'form-control datetimepicker-input'
    input_html_options[:value] ||= object.send(attribute_name).strftime('%b %d, %Y')

    input_group_div do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat div_button
    end
  end

  def div_button
    tag_attrs = {
      class: 'input-group-append',
      data:  { target: "##{object_name}_#{attribute_name}", toggle: 'datetimepicker' },
    }

    template.content_tag(:div, tag_attrs) do
      template.concat span_table
    end
  end

  def span_table
    template.content_tag(:div, class: 'input-group-text') do
      template.concat icon_table
    end
  end

  def icon_remove
    "<i class='glyphicon glyphicon-remove'></i>".html_safe
  end

  def icon_table
    "<i class='fas fa-calendar'></i>".html_safe
  end

  def input_group_div
    tag_attrs = {
      class: 'input-group date',
      data:  { target_input: 'nearest' },
      id:    "#{object_name}_#{attribute_name}",
    }

    template.content_tag(:div, tag_attrs) do
      yield
    end
  end
end
