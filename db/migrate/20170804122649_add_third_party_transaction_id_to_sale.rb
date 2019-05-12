# frozen_string_literal: true

class AddThirdPartyTransactionIdToSale < ActiveRecord::Migration[5.0]
  def change
    add_column :sales, :third_party_transaction_id, :string
  end
end
