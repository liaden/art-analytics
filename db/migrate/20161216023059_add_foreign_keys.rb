# frozen_string_literal: true

class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :artworks, :imports

    add_foreign_key :event_inventory_items, :events
    add_foreign_key :event_inventory_items, :merchandises

    add_foreign_key :events, :imports

    add_foreign_key :merchandise_sales, :merchandises
    add_foreign_key :merchandise_sales, :sales

    add_foreign_key :merchandises, :artworks
    add_foreign_key :merchandises, :imports

    add_foreign_key :sales, :events
  end
end
