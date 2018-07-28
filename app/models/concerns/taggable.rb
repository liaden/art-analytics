module Taggable
  extend ActiveSupport::Concern

  class << self
    def tagged_with_sql(on: nil, interpolate_name: :keys)
      "#{quoted_on(on)}tags ?& array[:#{interpolate_name}]"
    end

    def tagged_without_sql(on: nil, interpolate_name: :keys)
      "NOT #{tagged_with_sql(on: on, interpolate_name: interpolate_name)}"
    end

    def tagged_with_any_sql(on: nil, interpolate_name: :keys)
      "#{quoted_on(on)}tags ?| array[:#{interpolate_name}]"
    end

    def tagged_without_any_sql(on: nil, interpolate_name: :keys)
      "NOT #{tagged_with_any_sql(on: on, interpolate_name: interpolate_name)}"
    end

    def untagged_sql(on: nil)
      "#{quoted_on(on)}tags = NULL or #{quoted_on(on)}tags = '[]'::jsonb"
    end

    def tagged_sql(on: nil)
      "#{quoted_on(on)}tags != NULL and #{quoted_on(on)}tags != '[]'::jsonb"
    end

    private

    def quoted_on(name)
      name.nil? ? '' : "\"#{name}\"."
    end
  end

  included do
    # logical AND over tags
    scope :tagged_with,    ->(*tags) { where(tagged_with_sql,    keys: tags.flatten) }
    scope :tagged_without, ->(*tags) { where(tagged_without_sql, keys: tags.flatten) }

    # logical OR over tags
    scope :tagged_with_any,    ->(*tags) { where(tagged_with_any_sql,    keys: tags.flatten) }
    scope :tagged_without_any, ->(*tags) { where(tagged_without_any_sql, keys: tags.flatten) }

    scope :untagged, ->() { where(untagged_sql) }
  end

  # accept csv as an option as well as an array
  # convert singular item to array of itself as well
  def tags=(value)
    value = value.split(',') if value.is_a?(String)

    write_attribute(:tags, Array(value))
  end

  # convert nil back to empty array
  def tags
    Array(read_attribute(:tags))
  end

  class_methods do
    delegate :tagged_with_sql, :tagged_without_sql,
      :tagged_with_any_sql, :tagged_without_any_sql,
      :tagged_sql, :untagged_sql,
      to: Taggable

    def all_tags
      # should be more effecient in the future
      self.select(:tags).reduce(Set.new) do |result, record|
        result.union(record.tags)
      end.to_a
    end
  end
end
