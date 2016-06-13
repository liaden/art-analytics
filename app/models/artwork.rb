class Artwork < ActiveRecord::Base
  include Taggable
  include Importable

  validates :name, presence: true

  has_many :merchandises
end
