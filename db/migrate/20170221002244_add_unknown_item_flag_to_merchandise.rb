class AddUnknownItemFlagToMerchandise < ActiveRecord::Migration[5.0]
  def change
    add_column :merchandises, :unknown_item, :boolean, default: false
  end
end
