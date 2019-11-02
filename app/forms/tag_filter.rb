# frozen_string_literal: true

class TagFilter
  include ActiveModel::Model
  include Virtus.model

  PREPEND_WITH_OPTIONS       = %[and or not]
  MATCHING_MECHANISM_OPTIONS = %w[all some none]

  attribute :on,                 String
  attribute :matching_mechanism, String,        default: MATCHING_MECHANISM_OPTIONS.first
  attribute :tags,               Array[String], default: []
  attribute :prepend_with,       String

  validates :on, presence: true, unless: -> { tags.empty? }
  validates :tags, exclusion: { in: [nil] }
  validates :matching_mechanism, inclusion: { in: MATCHING_MECHANISM_OPTIONS }
  validates :prepend_with, inclusion: { in: PREPEND_WITH_OPTIONS, allow_blank: true }

  def initialize(params={})
    super(params)
    self.tags               ||= []
    self.matching_mechanism ||= 'all'
  end
end
