# frozen_string_literal: true

class AddSoldAtToSale < ActiveRecord::Migration[5.0]
  def change
    remove_column :sales, :sold_on, :date
    add_column :sales, :sold_at, :datetime
  end
end
