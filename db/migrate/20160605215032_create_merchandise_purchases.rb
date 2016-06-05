class CreateMerchandisePurchases < ActiveRecord::Migration
  def change
    create_table :merchandise_purchases do |t|
      t.integer :merchandise_id
      t.integer :purchase_id
    end
  end
end
