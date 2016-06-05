class CreateMerchandises < ActiveRecord::Migration
  def change
    create_table :merchandises do |t|
      t.integer :artwork_id
      t.string :name
      t.jsonb :tags
      t.date :released_on

      t.timestamps null: false
    end
  end
end
