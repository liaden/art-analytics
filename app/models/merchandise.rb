class Merchandise < ActiveRecord::Base
  include Taggable

  belongs_to :artwork

  validates :name, presence: true
  validates :artwork, presence: true
end
