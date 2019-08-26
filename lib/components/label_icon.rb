# frozen_string_literal: true

module LabelIcon
  def label_icon(wrapper_options={})
    icon = options[:label_icon] || wrapper_options[:label_icon]
    icon = translate_from_namespace(:label_icon) unless icon.is_a? String
    template.content_tag(:i, '', class: "m-1 fas fa-#{icon}")
  end

  def has_label_icon?
    options[:label_icon] != false && label_icon.present?
  end
end
SimpleForm.include_component(LabelIcon)
