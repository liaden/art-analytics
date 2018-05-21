module Taggable
  extend ActiveSupport::Concern

  included do
    Taggable.register(self)

    # logical AND over tags
    scope :tagged_with, ->(*tags) { where('tags ?& array[:keys]', keys: tags.flatten ) }

    # logical OR over tags
    scope :tagged_with_any, ->(*tags) { where('tags ?| array[:keys]', keys: tags.flatten) }

    scope :untagged, ->() { where("tags = NULL or tags = '[]'::jsonb") }
  end

  # accept csv as an option as well as an array
  # convert singular item to array of itself as well
  def tags=(value)
    value = value.split(',').uniq if value.is_a?(String)

    write_attribute(:tags, Array(value))
  end

  # convert nil back to empty array
  def tags
    Array(read_attribute(:tags))
  end

  class_methods do
    def all_tags
      # should be more effecient in the future
      self.select(:tags).reduce(Set.new) do |result, record|
        result.union(record.tags)
      end.to_a
    end

    def add_tag(tag, ids = [])
      dataset =
        if ids.empty?
          self
        else
          self.where(ids: ids)
        end

      dataset.execute(
        "UPDATE tags SET tags = tags || '[:tag]'", tag: tag
      )
    end

    def remove_tag_from(tag, ids = [])
      options
      dataset.execute(
        "UPDATE tags SET tags = tags - ':tag'
         WHERE ids IN (:ids)",
        tag: tag, ids: ids.join(',')
      )
    end
  end

  def self.register(klass)
    @taggable_classes ||= []
    @taggable_classes << klass
  end

  def self.registered
    @taggable_klasses ||= []
  end

  def self.tags_by_class
    registered.reduce({}) do |result, klass|
      result[klass.name] = klass.send(:all_tags)
    end
  end
end
