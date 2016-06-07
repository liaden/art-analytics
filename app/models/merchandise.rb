class Merchandise < ActiveRecord::Base
  include Taggable

  belongs_to :artwork

  has_many :merchandise_sales
  has_many :sales, through: :merchandise_sales

  validates :name, presence: true
  validates :artwork, presence: true
end
