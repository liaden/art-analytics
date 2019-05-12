# frozen_string_literal: true

class AddImportIdToEverything < ActiveRecord::Migration
  def change
    add_column :merchandises, :import_id, :integer
    add_column :artworks, :import_id, :integer
    add_column :events, :import_id, :integer
  end
end
