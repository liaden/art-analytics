class Artwork < ApplicationRecord
  include Taggable
  include Importable

  validates :name, presence: true

  has_many :merchandises
end
