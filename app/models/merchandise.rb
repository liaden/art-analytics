class Merchandise < ApplicationRecord
  include Taggable
  include Importable

  # optional to allow for unknown merchandise where
  # the artwork is not known
  belongs_to :artwork, optional: :unknown_item
  belongs_to :replaced_by, class_name: 'Merchandise'
  belongs_to :dimension

  has_many :merchandise_sales
  has_many :sales, through: :merchandise_sales

  has_many :event_inventory_items
  has_many :events, through: :event_inventory_items

  # valid cases:
  # * one unknown item for no artwork, and one uknown item for every artwork
  #     { unknown_item: true, name: '', artwork_id: nil }
  #     { unknown_item: true, name: '', artwork_id: 1 }
  # * unique name amongst known item for artwork
  #     { unknown_item: false, name: 'small', artwork_id: 1 }
  #     { unknown_item: false, name: 'large', artwork_id: 1 }
  # * name can be duplicated across artworks
  #     { unknown_item: false, name: 'small', artwork_id: 1 }
  #     { unknown_item: false, name: 'small', artwork_id: 2 }
  validates_uniqueness_of :name, scope: [:artwork_id, :unknown_item]

  # require name for known items
  validates :name, presence: true, if: :known_item?

  # validate uniqueness of the artwork_id for unknown_items
  # allows nil for unknown item for an unknown artwork
  validates_uniqueness_of :artwork_id, scope: :unknown_item, if: :unknown_item

  scope :active, -> { where(replaced_by_id: nil) }
  scope :replaced, -> { where.not(replaced_by_id: nil) }

  scope :known, -> { where(uknown_item: false) }
  scope :unknown, -> { where(unknown_item: true) }

  def self.create_unknown_for(artwork)
    create!(artwork: artwork, unknown_item: true, name: '')
  end

  def known_item?
    !unknown_item
  end

  def unknown_artwork?
    unknown_item && artwork_id.nil?
  end

  def self.unknown_artwork_item
    where(artwork_id: nil, name: '', unknown_item: true).first
  end
end
