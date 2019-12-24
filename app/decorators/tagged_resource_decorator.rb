class TaggedResourceDecorator < BaseDecorator
  def checkbox(tag)
    h.check_box_tag(@object.id.to_s, tag, @object.tags.include?(tag))
  end

  def clear_tags_link
    options = {
      title: 'Clear Tags',
      class: 'text-danger clear-tags',
    }

    icon = h.content_tag(:i, '', class: 'fas fa-tag')

    if object.tags.empty?
      h.content_tag(:span, class: 'text-black-50') { icon }
    else
      h.link_to('javascript:void(0)', options) { icon }
    end
  end

  def resource_link
    h.link_to(@object.name, h.polymorphic_path(@object))
  end

  def context_cell(attr)
    h.content_tag(:td) do
      text = @object.send(attr) if @object.respond_to?(attr)
      h.content_tag(:span, text, class: 'd-block text-nowrap')
    end
  end

  def tags_path
    "#{@object.model_name.singular_route_key}/#{@object.id}/tags"
  end

  def resource_type
    @object.class
  end

  delegate :name,
    to: :object
end
