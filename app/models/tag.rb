class Tag
  include ActiveModel::Model

  attr_accessor :id

  attr_reader :resources

  def initialize(params)
    raise ArgumentError, "Conflicting arguments: resource, :resources" if params.key?(:resource) && params.key?(:resources)

    params[:resources] = [params.delete(:resource)] if params[:resource]

    @resources = []
    super(params)
  end

  def matches
    return @matches if defined?(@matches)

    @matches = resource_classes.map do |klass|
      [ match_key(klass), klass.tagged_with(@id) ]
    end.to_h
  end

  def matches_for(key)
    matches[match_key(key)]
  end

  def resources=(value)
    @resources = value.map { |name| Taggable.resource(name) }
  end

  def resource_classes
    resources.empty? ? Taggable.resources : resources
  end

  def matching_resource_classes
    resource_classes.select { |k| matches_for(k).any? }
  end

  def matching_resources
    matches.keys.select { |k| matches[k].any? }
  end

  def to_h
    { id: id, matches: match_records_to_hash }
  end

  def to_json
    to_h.to_json
  end

  private

  def match_records_to_hash
    matches.transform_values do |records|
      records.map { |v| { id: v.id, name: v.name } }
    end
  end

  def match_key(key)
    key.is_a?(Class) ? key.name.downcase : key
  end
end
