# frozen_string_literal: true

class CreateEventChartConfig < ActiveRecord::Migration[5.0]
  def change
    create_table :event_chart_configs do |t|
      t.string :grouping, null: false
      t.string :metric, null: false
      t.string :name

      t.datetime :date_after, null: false
      t.datetime :date_before, null: false
    end
  end
end
