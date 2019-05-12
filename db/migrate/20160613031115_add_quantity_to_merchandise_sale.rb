# frozen_string_literal: true

class AddQuantityToMerchandiseSale < ActiveRecord::Migration
  def change
    add_column :merchandise_sales, :quantity, :integer, default: 0
  end
end
