# frozen_string_literal: true

class Bootstrap::TagFilterField
  def initialize(builder, template)
    @builder  = builder
    @template = template
  end

  def render(method, options = {})
    data = {
      data: {
        resource: tagging_resource(method),
        # lastpass is annoying
        lpignore: true,
      },
      value: value_for(method),
    }

    @builder.text_field(method, data.merge!(options))
  end

  private

  def value_for(method)
    return @attribute_value if @attribute_value

    val = @builder.object.send(method)
    val = val.tags if val.is_a?(TagFilter)

    @attribute_value = (val == []) ? '' : Array(val).join(',')
  end


  def tagging_resource(method)
    # TODO: if assigned value is a TagFilter,
    # it should know what resource
    resource, = method.to_s.rpartition('_tag_filter')

    if resource.empty?
      @builder.object.class.name.downcase
    else
      resource
    end
  end
end
