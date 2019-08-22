# frozen_string_literal: true

class TagFilterInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    attribute_value

    input_html_options[:'data-resource'] = tagging_resource
    input_html_options[:value]           = attribute_value

    wrapper_options[:as] = 'string'

    @builder.text_field(attribute_name, input_html_options)
  end

  # untagged items will by default show '[]'
  def attribute_value
    return @attribute_value if @attribute_value

    value = object.send(attribute_name)
    value = value.tags if value.is_a?(TagFilter)

    @attribute_value = (value == []) ? '' : Array(value).join(',')
  end

  private

  def tagging_resource
    resource, = attribute_name.to_s.rpartition('_tag_filter')

    if resource.empty?
      object.class.name.downcase
    else
      resource
    end
  end
end
