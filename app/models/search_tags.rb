class SearchTags
  def self.on(*resources)
    return new(*Taggable.resource_names) if resources.empty?

    new(*resources)
  end

  def initialize(*resources)
    raise ArgumentError, "Must specify resources" if resources.size == 0

    @resource_names = resources
  end

  def with_prefix(prefix)
    @resource_names.map do |name|
      [name, class_for(name).tags_with_prefix(prefix) ]
    end.to_h
  end

  private

  def class_for(name)
    Taggable.resources_by_name[name]
  end
end
