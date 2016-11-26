class EventInventoryItem < ActiveRecord::Base
  belongs_to :event
  belongs_to :merchandise
end
