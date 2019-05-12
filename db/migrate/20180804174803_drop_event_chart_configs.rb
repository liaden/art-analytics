# frozen_string_literal: true

class DropEventChartConfigs < ActiveRecord::Migration[5.2]
  def change
    drop_table :event_chart_configs
  end
end
