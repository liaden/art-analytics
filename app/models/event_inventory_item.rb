# frozen_string_literal: true

class EventInventoryItem < ApplicationRecord
  belongs_to :event
  belongs_to :merchandise

  validate :must_be_known_item

  private

  def must_be_known_item
    errors.add(:merchandise, 'cannot be unknown item') if merchandise.unknown_item?
  end
end
