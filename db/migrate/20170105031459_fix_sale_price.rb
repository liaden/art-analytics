# frozen_string_literal: true

class FixSalePrice < ActiveRecord::Migration[5.0]
  def change
    remove_column :sales, :sale_price
    add_monetize :sales, :sale_price, currency: { present: false }
  end
end
