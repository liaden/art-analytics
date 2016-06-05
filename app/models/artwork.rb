class Artwork < ActiveRecord::Base
  include Taggable

  validates :name, presence: true

  has_many :merchandises
end
