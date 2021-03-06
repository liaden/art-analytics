# frozen_string_literal: true

class Sale < ApplicationRecord
  include Taggable
  include Unnameable

  has_many :merchandise_sales
  has_many :merchandises, through: :merchandise_sales

  belongs_to :event

  scope :unknown_items, -> { joins(:merchandises).where(merchandises: { unknown_item: true }) }

  scope :record_by_hand, -> { where(third_party_transaction_id: null) }
  scope :record_by_square, -> { where('third_party_transaction_id LIKE "SQUARE%"') }

  monetize :sale_price_cents

  validates :sale_price_cents, presence: true
  # validates :merchandise_sales, length: { minimum: 1, too_short: "must have at least one asociated sold item" }

  validate :during_event

  private

  def during_event
    if event.present?
      unless event.time_period.include?(sold_at.to_date)
        errors.add(
          :sold_at,
          "sold date #{sold_at} not during event: #{event.time_period} "
        )
      end
    end
  end
end
