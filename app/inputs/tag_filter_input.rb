# frozen_string_literal: true

class TagFilterInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    wrapper_options[:input_html] ||= {}
    wrapper_options[:input_html].merge!(data: { role: :tagsinput })
    wrapper_options[:as] = 'string'
    input_group_div do
      @builder.text_field(attribute_name, input_html_options)
    end
  end

  # untagged items will by default show '[]'
  def attribute_value
    return @attribute_value  if @attribute_value
    value = object.send(attribute_name)
    @attribute_value = value == [] ? '' : value.join(',')
  end

  private

  def input_group_div
    template.content_tag(:div) do
      yield
    end
  end
end
