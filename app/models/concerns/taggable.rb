# frozen_string_literal: true

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

    def make_tag_scope(query, tags, with_specified_tags)
      tags.flatten!

      if tags.compact.empty?
        query
      else
        query.where(with_specified_tags, keys: tags)
      end
    end

    private

    def quoted_on(name)
      name.nil? ? '' : "\"#{name}\"."
    end
  end

  included do
    # logical AND over tags
    scope :tagged_with,    ->(*tags) { Taggable.make_tag_scope(self, tags, tagged_with_sql) }
    scope :tagged_without, ->(*tags) { Tagggable.make_tag_scope(self, tags, tagged_without_sql) }

    # logical OR over tags
    scope :tagged_with_any,    ->(*tags) { Taggable.make_tag_scope(self, tags, tagged_with_any_sql) }
    scope :tagged_without_any, ->(*tags) { Taggable.make_tag_scope(self, tags, tagged_without_any_sql) }

    scope :untagged, ->() { where(untagged_sql) }
  end

  # accept csv as an option as well as an array
  # convert singular item to array of itself as well
  def tags=(value)
    value = value.split(',') if value.is_a?(String)

    write_attribute(:tags, Array(value).map(&:strip).uniq)
  end

  class_methods do
    delegate :tagged_with_sql, :tagged_without_sql,
             :tagged_with_any_sql, :tagged_without_any_sql,
             :tagged_sql, :untagged_sql,
             to: Taggable

    # TODO: refactor such that it can work as a scope? merge with all_tags?
    def tags_with_prefix(prefix)
      bind_variables = { tag_prefix: "\"#{prefix}%" }

      parameritized_query = <<~SQL
        SELECT json_agg(tag) AS matching_tags
        FROM
          (SELECT distinct jsonb_array_elements(tags) AS tag FROM #{table_name}) tags
        WHERE tag::text like :tag_prefix
      SQL

      query   = ActiveRecord::Base.sanitize_sql([parameritized_query, bind_variables])
      results = ActiveRecord::Base.connection.exec_query(query).to_a.first.try(:[], 'matching_tags')

      JSON.parse(results || '[]')
    end

    def all_tags
      result = ActiveRecord::Base.connection.execute(<<~SQL).to_a.first['tags']
        SELECT json_agg(tag) AS tags
        FROM (SELECT distinct jsonb_array_elements(tags) AS tag FROM #{table_name}) tag_set
      SQL

      JSON.parse(result || '[]')
    end

  end
end
