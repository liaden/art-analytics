# frozen_string_literal: true

class Bootstrap::Base
  def initialize(builder, template)
    @builder  = builder
    @template = template
  end

  protected

  def object
    @builder.object
  end

  def human_attribute_name(method, value)
    object.class.human_attribute_name("#{method}.#{value}")
  end
end
