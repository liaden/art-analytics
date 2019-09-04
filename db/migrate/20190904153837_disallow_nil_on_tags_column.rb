class DisallowNilOnTagsColumn < ActiveRecord::Migration[5.2]
  def change
    change_column :merchandises, :tags, :jsonb, default: [], null: false
    change_column :artworks,     :tags, :jsonb, default: [], null: false
    change_column :events,       :tags, :jsonb, default: [], null: false
    change_column :sales,        :tags, :jsonb, default: [], null: false
  end
end
