# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  def self.resources
    @resources ||=
      resource_names.map do |name|
        name.camelize.constantize
      end
  end

  def self.resources_by_name
    resources.index_by { |c| c.name.downcase }.with_indifferent_access
  end

  # Use DB schema to find all possible candidate tables:
  #  * has a tags:jsonb column
  #
  # We then try to load the constant that is defined. If
  # it exists, we are leave the name in the list.
  def self.resource_names
    @resource_names ||=
      begin
        query = <<~SQL
          select table_name
          from information_schema.columns
          where column_name = 'tags'
            and data_type = 'jsonb';
        SQL

        ActiveRecord::Base.connection.execute(query).to_a.map do |data|
          data['table_name'].singularize
        end.select do |name|
          name.camelize.constantize rescue nil
        end
      end
  end

  def self.resource(name)
    resources_by_name[name.downcase]
  end

  # [['t1', 't2']] -> ['t1', 't2']
  # ['t1', 't1']   -> ['t1']
  # [' t1 ']       -> ['t1']
  def self.sanitize_tag_list(tags)
    tags = tags.flatten
    tags.compact!
    tags.map!(&:strip)
    tags.uniq!
    tags
  end

  class << self
    def tagged_with_sql(on: nil, interpolate_name: :keys)
      "coalesce(#{quoted_on(on)}tags, '[]'::jsonb) ?& array[:#{interpolate_name}]"
    end

    def tagged_without_sql(on: nil, interpolate_name: :keys)
      "NOT #{tagged_with_sql(on: on, interpolate_name: interpolate_name)}"
    end

    def tagged_with_any_sql(on: nil, interpolate_name: :keys)
      "coalesce(#{quoted_on(on)}tags, '[]'::jsonb) ?| array[:#{interpolate_name}]"
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
      tags = Taggable.sanitize_tag_list(tags)

      if tags.empty?
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

  included do |base|
    # In dev/test, we have code reloading, so delete the old version by name when we have reloaded ourselves
    # If we don't do this, we will end up using old versions of the class that fail to load Taggable related methods
    Taggable.resources.delete_if { |klass| klass.name == base.name }
    Taggable.resources << base

    # logical AND over tags
    scope :tagged_with,    ->(*tags) { Taggable.make_tag_scope(self, tags, tagged_with_sql) }
    scope :tagged_without, ->(*tags) { Taggable.make_tag_scope(self, tags, tagged_without_sql) }

    # logical OR over tags
    scope :tagged_with_any,    ->(*tags) { Taggable.make_tag_scope(self, tags, tagged_with_any_sql) }
    scope :tagged_without_any, ->(*tags) { Taggable.make_tag_scope(self, tags, tagged_without_any_sql) }

    scope :untagged, ->() { where(untagged_sql) }
  end

  # accept csv as an option as well as an array
  # convert singular item to array of itself as well
  def tags=(value)
    value = value.split(',') if value.is_a?(String)

    write_attribute(:tags, Taggable.sanitize_tag_list(Array(value)))
  end

  def delete_tags(*values)
    return if values.empty?

    self.tags -= values
  end

  class_methods do
    delegate :tagged_with_sql, :tagged_without_sql,
             :tagged_with_any_sql, :tagged_without_any_sql,
             :tagged_sql, :untagged_sql,
             to: Taggable

    # TODO: refactor such that it can work as a scope? merge with all_tags?
    def tags_with_prefix(prefix)
      prefix = prefix.strip

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

    # TODO: handle multiples with a reduce
    def updating_all_timestamp_sql
      update_col = timestamp_attributes_for_update_in_model.first

      ", #{update_col} = ?" if update_col
    end

    def delete_tags(*values)
      values = Taggable.sanitize_tag_list(values)

      return if values.empty?

      delete_tags_sql = "tags = coalesce(tags, '[]'::jsonb) - array[?]#{updating_all_timestamp_sql}"

      query_parts = [delete_tags_sql, values]
      query_parts << Time.now if timestamp_attributes_for_update_in_model.any?

      tagged_with_any(*values).update_all(query_parts)
    end

    def insert_tags(*values)
      values = Taggable.sanitize_tag_list(values)

      return if values.empty?

      insert_tags_sql = <<~SQL
        tags = (
            select json_agg(tag) from (
                select distinct jsonb_array_elements(
                    coalesce(e2.tags, '[]'::jsonb) || ?::jsonb) as tag
                 from "#{table_name}" e2
                where id = e2.id) new_tags
            )#{updating_all_timestamp_sql}
      SQL

      query_parts = [insert_tags_sql, values.to_json]
      query_parts << Time.now if timestamp_attributes_for_update_in_model.any?

      tagged_without(*values).update_all(query_parts)
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
