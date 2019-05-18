# frozen_string_literal: true

class ToggleCollectionInput < SimpleForm::Inputs::CollectionInput
  def input(wrapper_options)
    @merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    translate_collection
    template.content_tag(:div, class: 'btn-group btn-group-toggle', data: { toggle: 'buttons' }) do
      template.concat all_buttons
    end
  end

  def collection
    @collection ||= object.class.const_get("#{attribute_name.upcase}_OPTIONS").map(&:to_sym)
  rescue NameError
    super
  end

  def all_buttons
    collection.map do |label_text, value|
      toggle_button_tag(label_text, value)
    end.join.html_safe
  end

  def toggle_button_tag(radio_label_text, radio_button_value)
    template.content_tag(:label, class: toggle_label_classes(radio_button_value)) do
      template.concat(@builder.radio_button(attribute_name, radio_button_value) + radio_label_text.html_safe)
    end
  end

  def attribute_value
    @attribute_value ||= object.send(attribute_name)
  end

  def toggle_label_classes(value)
    "btn btn-secondary #{'active' if value == attribute_value.to_s} #{@merged_input_options[:toggle_class]}"
  end
end
