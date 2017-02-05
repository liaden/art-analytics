class Artwork < ApplicationRecord
  include Taggable
  include Importable

  validates :name, presence: true

  has_many :merchandises

  def self.unknown_item
    Merchandise.unknown_artwork_item
  end

  def unknown_item
    merchandises.where(unknown_item: true).first
  end
end
