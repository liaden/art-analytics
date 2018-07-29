class Artwork < ApplicationRecord
  include Taggable
  include Importable

  validates :name, presence: true, uniqueness: true

  has_many :merchandises

  belongs_to :replaced_by, class_name: 'Artwork', optional: true

  scope :known, -> { where(unknown_item: false) }

  scope :active, -> { where(replaced_by_id: nil) }
  scope :replaced, -> { where.not(replaced_by_id: nil) }

  def self.unknown_item
    Merchandise.unknown_artwork_item
  end

  def unknown_item
    merchandises.where(unknown_item: true).first
  end
end
