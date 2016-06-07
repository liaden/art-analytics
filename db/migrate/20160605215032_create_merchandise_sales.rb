class CreateMerchandiseSales < ActiveRecord::Migration
  def change
    create_table :merchandise_sales do |t|
      t.integer :merchandise_id
      t.integer :sale_id
    end
  end
end
