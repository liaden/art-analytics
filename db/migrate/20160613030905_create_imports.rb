class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.text :note
      t.text :import_file_data

      t.timestamps null: false
    end
  end
end
