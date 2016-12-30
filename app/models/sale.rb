class Sale < ApplicationRecord
  include Taggable

  has_many :merchandise_sales
  has_many :merchandises, through: :merchandise_sales

  belongs_to :event

  validates :sale_price, presence: true
  #validates :merchandise_sales, length: { minimum: 1, too_short: "must have at least one asociated sold item" }

  validate :during_event

  private

  def during_event
    if event.present?
      errors.add(:sold_on, "sold date #{sold_on} not during event: #{event.time_period} ") unless event.time_period.include?(sold_on)
    end
  end
end
