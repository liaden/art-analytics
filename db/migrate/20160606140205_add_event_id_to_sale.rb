# frozen_string_literal: true

class AddEventIdToSale < ActiveRecord::Migration
  def change
    add_column :sales, :event_id, :integer
  end
end
