# frozen_string_literal: true

class AddOrderingOptionToEventChartConfig < ActiveRecord::Migration[5.1]
  def change
    add_column :event_chart_configs, :ordering, :string
  end
end
