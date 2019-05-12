# frozen_string_literal: true

class TagFilterFragment
  def initialize(options)
    @options = options
  end

  def to_sql(prepend_with=nil)
    # raise self.errors unless valid?
    return '' if @options.tags.empty?
    sanitize_sql(build_sql(prepend_with || @options.prepend_with))
  end

  private

  def build_sql(prepend_with)
    inner = self.send("filter_by_#{@options.matching_mechanism}")
    return inner if prepend_with.nil?
    "#{prepend_with.upcase} (#{inner})"
  end

  def filter_by_all
    Taggable.tagged_with_sql(on: @options.on)
  end

  def filter_by_some
    Taggable.tagged_with_any_sql(on: @options.on)
  end

  def filter_by_none
    Taggable.tagged_without_sql(on: @options.on)
  end

  def sanitize_sql(sql)
    ActiveRecord::Base.sanitize_sql([sql, { keys: @options.tags }])
  end
end
