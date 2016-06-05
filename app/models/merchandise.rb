class Merchandise < ActiveRecord::Base
  include Taggable

  belongs_to :artwork

  has_many :merchandise_purchases
  has_many :purchases, through: :merchandise_transactions

  validates :name, presence: true
  validates :artwork, presence: true
end
