class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.date :started_at
      t.date :ended_at
      t.jsonb :tags

      t.timestamps null: false
    end
  end
end
