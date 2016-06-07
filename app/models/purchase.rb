class Purchase < ActiveRecord::Base
  include Taggable

  has_many :merchandise_purchases
  has_many :merchandises, through: :merchandise_purchases

  belongs_to :event

  validates :sale_price, presence: true
  validates :merchandise_purchases, length: { minimum: 1 }

  validate :during_event

  private

  def during_event
    if event.present?
      errors.add(:sold_on, "sold date #{sold_on} not during event: #{event.time_period} ") unless event.time_period.include?(sold_on)
    end
  end
end
