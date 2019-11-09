# Expected uses for a given field
# = f.text_field :username, label: :ldap_username
# = f.text_field :username, label: 'ldap_username
# = f.text_field :username, label: { text: :ldap_userpanem class: 'exta-label-class' }
# = f.text_field :username, class: 'extra-text-field-class'
#
# Expected uses for group:
# = f.group { f.text_field :username }
# = f.group(class: 'form-row') { f.text_field :username }
#
# Expected uses of form_for to build form:
# = form_for(@user)
# = form_for(@user, class: 'form-inline')
module Bootstrap
  class FormBuilder < ActionView::Helpers::FormBuilder
    def initialize(record_name, record_object, template, options)
      super(record_name, record_object, template, options)
    end

    def row(&block)
      raise ArgumentError, 'Block required' unless block

      @template.content_tag(:div, class: 'form-row', &block)
    end

    def group(options = {}, &block)
      raise ArgumentError, 'Block required' unless block

      # allow template to call `= f.group(...)` and we do not double layer
      return block.call if @grouped

      @grouped = true
      div(class: "form-group #{options[:class]}", &block).tap { @grouped = false }
    end

    def input_group(options = {}, &block)
      raise ArgumentError, 'Block required' unless block

      div(class: "input-group #{options[:class]}", &block)
    end

    def select_field(method, choices = nil, options = {}, html_options = {}, &block)
      group do
        label(method, options) +
          select(method, choices || default_collection_for(method), options, html_options, &block)
      end
    end

    def text_field(method, options = {})
      options = options.dup
      return super(method, options) if options.delete(:bypass)

      group do
        label(method, options) + super(method, insert_defaults(options, class: 'form-control'))
      end
    end

    def password_field(method, options = {})
      options = options.dup

      group do
        label(method, options) + super(method, insert_defaults(options, class: 'form-control'))
      end
    end

    def number_field(method, options = {})
      options = options.dup

      group do
        label(method, options) + super(method, insert_defaults(options, class: 'form-control'))
      end
    end

    def calendar_field(method, options = {})
      CalendarField.new(self, @template).render(method, options)
    end

    def tag_filter_field(method, options = {})
      TagFilterField.new(self, @template).render(method, options)
    end

    def toggle_field(method, options = {})
      ToggleCollectionField.new(self, @template).
        render(method, default_collection_for(method), options)
    end

    def submit(text, options = {})
      options = options.dup
      super(text, insert_defaults(options, class: 'btn btn-primary'))
    end

    def button(text, options = {})
      options = options.dup
      super(text, insert_defaults(options, class: 'btn btn-primary'))
    end

    def label(method, text = nil, options = {})
      options, text = text, nil if text.is_a?(Hash)

      if options.dig(:label, :hidden)
        options.delete(:label)
        return ''.html_safe
      end

      if tooltip = options.delete(:tooltip)
        options.merge!(
          data: {
            toggle:    'tooltip',
            placement: tooltip.fetch(:placement, 'right')
          },
        )
      end

      text ||= options.is_a?(Hash) ? options.delete(:text) : options
      text ||= object.class.human_attribute_name(method)

      label_text = label_icon(text, options[:label_icon])
      super(method, label_text, options)
    end

    private

    def label_icon(text, icon)
      return text unless icon

      icon = translate_from_namespace(:label_icon) unless icon.is_a? String
      "#{@template.content_tag(:i, '', class: "m-1 fas fa-#{icon}")} #{text}".html_safe
    end

    # future candidates include data attributes hash
    def insert_defaults(options, defaults = { class: nil })
      options.dup.tap do |results|
        klass = results[:class] || results.delete('class')

        results[:class] = "#{defaults[:class]} #{klass}"
      end
    end

    def div(options = {}, &block)
      @template.content_tag(:div, options, &block)
    end

    def default_collection_for(method)
      object.class.const_get("#{method.upcase}_OPTIONS").map(&:to_sym)
    end

    def tooltip_hash(placement: 'right', text: nil, i18n: nil)
      tooltip_text =
        if i18n
          I18n.t("hints.#{i18n}")
        else
          text
        end

      {
        data:  {
          toggle:    'tooltip',
          placement: placement,
        },
        title: tooltip_text
      }
    end
  end
end
