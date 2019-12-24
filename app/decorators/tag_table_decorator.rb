class TagTableDecorator
  include ActiveModel::Model
  include Helpable

  attr_reader :tags

  def initialize(items, tags)
    @items = items
    @tags  = tags
  end

  def each_taggable(&block)
    @items.each do |item|
      yield item
    end
  end

  def delete_tag_link(tag)
    url  = routes.scoped_tag_path(resource_type.name.downcase, tag)
    opts = {
      title: 'Delete tag',
      class: 'text-danger',
      method: :delete
    }

    h.link_to(url, opts) do
      h.content_tag(:i, '', class: 'fas fa-trash')
    end
  end

  def new_tag_link
    h.link_to('#', class: 'text-success') do
      h.content_tag(:i, '', class: 'fas fa-plus')
    end
  end

  def column_filter(attr)
    options = {
      placeholder: t("footer.#{attr}"),
      class: 'form-control form-control-sm'
    }

    h.content_tag(:div, class: 'form-group mb-0') do
      h.text_field_tag(:name, '', options)
    end
  end

  def tag_filter
    options = {
      class: 'form-control form-control-sm',
      placeholder: I18n.t('tag_filter', scope: [:activerecord, :tag_table]),
      style: 'max-width: 20rem',
      data: { 'tagify-skip': true },
    }

    h.content_tag(:div, class: 'form-group mb-0') do
      h.text_field_tag 'tagsearch', '', options
    end
  end

  def header_for(tag)
    h.content_tag(:span, class: 'tag-col-header') do
      h.link_to(tag, routes.scoped_tag_path(resource_type.name.downcase, tag))
    end
  end

  # the bounding box in css is prior to applying rotation
  # so make last column thicker to fit the last tag
  #
  # note: this obviously fails if last tag is short and
  # second to last tag is looooooong
  def offset_right_size
    num = @tags.last.size/3.0 + 0.25

    h.content_tag(:th, style: "min-width: #{num}em;", rowspan: 2) do
      "&nbsp;".html_safe
    end
  end

  def context_columns
    return [:name, :year] if resource_type == Event

    [:name]
  end

  def context_header(attr)
    styling = 'min-width: 9rem' if attr.to_s.downcase == 'name'

    h.content_tag(:th, style: styling, class: 'context-col') do
      attr.to_s.capitalize
    end
  end

  private

  def resource_type
    @items.first.resource_type
  end

  def resource_name
    resource_type.model_name.singular_route_key
  end

  def t(attr)
    I18n.t(
      attr,
      scope: [ :activerecord, :tag_table, resource_name ]
    )
  end
end
