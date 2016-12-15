class MerchandiseSale < ActiveRecord::Base
  belongs_to :merchandise
  belongs_to :sale

  validates :merchandise, presence: true
  validates :sale, presence: true
  validates :quantity, presence: true

  validates_numericality_of :quantity, greater_than: 0
end
