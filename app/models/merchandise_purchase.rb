class MerchandisePurchase < ActiveRecord::Base
  belongs_to :merchandise
  belongs_to :purchase

  validates :merchandise, presence: true
  validates :purchase, presence: true
end
