class Purchase < ActiveRecord::Base
  include Taggable

  has_many :merchandise_purchases
  has_many :merchandises, through: :merchandise_purchases

  validates :sale_price, presence: true
  validates :merchandise_purchases, length: { minimum: 1 }
end
