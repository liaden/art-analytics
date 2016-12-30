class EventInventoryItem < ApplicationRecord
  belongs_to :event
  belongs_to :merchandise
end
