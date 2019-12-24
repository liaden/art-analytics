class BaseDecorator
  include Helpable

  def self.wrap(items)
    items.map { |i| new(i) }
  end

  def initialize(object)
    @object = object
  end

  protected

  def object
    @object
  end
end
