# frozen_string_literal: true

class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.integer :sale_price
      t.integer :list_price
      t.date :sold_on
      t.jsonb :tags
      t.text :note

      t.timestamps null: false
    end
  end
end
