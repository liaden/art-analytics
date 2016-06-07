class MerchandiseSale < ActiveRecord::Base
  belongs_to :merchandise
  belongs_to :sale

  validates :merchandise, presence: true
  validates :sale, presence: true
end
