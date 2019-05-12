# frozen_string_literal: true

class CreateDimensions < ActiveRecord::Migration[5.1]
  def change
    create_table :dimensions do |t|
      t.decimal :width, null: false
      t.decimal :height, null: false
      t.decimal :thickness, null: false, default: 0

      t.timestamps
    end

    add_index :dimensions, [:width, :height, :thickness], unique: true
  end
end
