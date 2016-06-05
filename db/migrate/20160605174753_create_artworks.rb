class CreateArtworks < ActiveRecord::Migration
  def change
    create_table :artworks do |t|
      t.string :name
      t.jsonb :tags

      t.timestamps null: false
    end
  end
end
