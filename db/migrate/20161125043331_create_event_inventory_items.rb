# frozen_string_literal: true

class CreateEventInventoryItems < ActiveRecord::Migration
  def change
    create_table :event_inventory_items do |t|
      t.integer :event_id
      t.integer :merchandise_id
    end

    add_index :event_inventory_items, [:event_id, :merchandise_id], unique: true
  end
end
