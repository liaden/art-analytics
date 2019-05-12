# frozen_string_literal: true

class AddReplacedByColumnToArtworksAndMerchandises < ActiveRecord::Migration[5.1]
  def change
    add_column :artworks, :replaced_by_id, :integer
    add_foreign_key :artworks, :artworks, column: :replaced_by_id

    add_column :merchandises, :replaced_by_id, :integer
    add_foreign_key :merchandises, :merchandises, column: :replaced_by_id
  end
end
