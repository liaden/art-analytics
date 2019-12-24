# frozen_string_literal: true

class Event < ApplicationRecord
  include Taggable
  include Importable
  include Nameable

  trigger.before(:insert) do
    "NEW.full_name :=  NEW.name || '-' || EXTRACT(year from NEW.started_at);"
  end

  trigger.before(:update).of(:name, :started_at) do
    "NEW.full_name :=  NEW.name || '-' || EXTRACT(year from NEW.started_at);"
  end

  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true

  validate :starts_before_ends

  has_many :sales

  has_many :event_inventory_items
  has_many :merchandises, through: :event_inventory_items

  def time_period
    started_at..ended_at
  end

  def duration
    return nil if started_at.nil? || ended_at.nil?
  end

  def duration=(value)
    raise "Setting duration when Event#started_at is not set." if started_at.nil? && ended_at.present?

    # 1 day event starts and ends on the same day
    days = value.to_i - 1
    raise "Bad value #{value}"  if days < 0

    ended_at = started_at + days
  end

  private

  def starts_before_ends
    if started_at && ended_at
      if ended_at < started_at
        errors.add(:ended_at, "End date (#{ended_at}) is less than start date (#{started_at})")
      end
    end
  end
end
