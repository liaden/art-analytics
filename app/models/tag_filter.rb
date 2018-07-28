class TagFilter
  include ActiveModel::Model
  include ActiveModel::Callbacks


  PREPEND_WITH_OPTIONS = %[and or not]
  MATCHING_MECHANISM_OPTIONS = %w[all some none]

  attr_accessor :on, :matching_mechanism, :tags, :prepend_with

  validates :on, presence: true, unless: -> { tags.empty? }
  validates :tags, exclusion: { in: [ nil ] }
  validates :matching_mechanism, inclusion: { in: MATCHING_MECHANISM_OPTIONS }
  validates :prepend_with, inclusion: { in: PREPEND_WITH_OPTIONS, allow_blank: true }

  def initialize(params = {})
    super(params)
    self.tags ||= []
    self.matching_mechanism ||= 'all'
  end

  def to_sql
    #raise self.errors unless valid?
    return '' if tags.empty?
    sanitize_sql(build_sql)
  end

  private

  def build_sql
    inner = self.send("filter_by_#{matching_mechanism}")
    return inner if prepend_with.nil?
    "#{prepend_with.upcase} (#{inner})"
  end

  def filter_by_all
    Taggable.tagged_with_sql(on: on)
  end

  def filter_by_some
    Taggable.tagged_with_any_sql(on: on)
  end

  def filter_by_none
    Taggable.tagged_without_sql(on: on)
  end

  def sanitize_sql(sql)
    ActiveRecord::Base.sanitize_sql([sql, {keys: tags}])
  end
end
