class Event < ActiveRecord::Base
  include Taggable
  include Importable

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

  private

  def starts_before_ends
    if started_at && ended_at
      if ended_at < started_at
        errors.add(:ended_at, "End date (#{ended_at}) is less than start date (#{started_at})")
      end
    end
  end
end
