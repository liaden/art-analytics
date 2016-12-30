class Merchandise < ApplicationRecord
  include Taggable
  include Importable

  belongs_to :artwork

  has_many :merchandise_sales
  has_many :sales, through: :merchandise_sales

  validates :name, presence: true
end
