# frozen_string_literal: true

class AddDimensionToMerchandises < ActiveRecord::Migration[5.1]
  def change
    add_column :merchandises, :dimension_id, :integer
    # add_foreign_key :merchandises, column: :dimension_id
  end
end
