class MerchandiseSale < ApplicationRecord
  belongs_to :merchandise
  belongs_to :sale

  validates :quantity, presence: true
  validates_numericality_of :quantity, greater_than: 0
end
