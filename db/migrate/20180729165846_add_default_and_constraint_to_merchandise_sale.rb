# frozen_string_literal: true

class AddDefaultAndConstraintToMerchandiseSale < ActiveRecord::Migration[5.2]
  def change
    add_index :merchandise_sales, [:sale_id, :merchandise_id], unique: true
    change_column_default :merchandise_sales, :quantity, from: 0, to: 1
  end
end
