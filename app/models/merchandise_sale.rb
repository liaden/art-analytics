class MerchandiseSale < ApplicationRecord
  belongs_to :merchandise
  belongs_to :sale

  has_many :other_sold_items,
    ->(ms) { where.not(sale: { merchandise_sales: { id: ms.id } }) },
    through: :sale, source: :merchandise_sales

  validates :quantity, presence: true
  validates_numericality_of :quantity, greater_than: 0
end
