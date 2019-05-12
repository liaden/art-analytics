# frozen_string_literal: true

# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersEventsInsertOrEventsUpdate < ActiveRecord::Migration
  def up
    add_column :events, :full_name, :string

    create_trigger("events_before_insert_row_tr", generated: true, compatibility: 1)
        .on("events")
        .before(:insert) do
      "NEW.full_name :=  NEW.name || '-' || EXTRACT(year from NEW.started_at);"
    end

    create_trigger("events_before_update_of_name_started_at_row_tr", generated: true, compatibility: 1)
        .on("events")
        .before(:update)
        .of(:name, :started_at) do
      "NEW.full_name :=  NEW.name || '-' || EXTRACT(year from NEW.started_at);"
    end

    add_index :events, :full_name, unique: true
  end

  def down
    drop_column :events, :full_name

    drop_trigger("events_before_insert_row_tr", "events", generated: true)

    drop_trigger("events_before_update_of_name_started_at_row_tr", "events", generated: true)

    drop_index :events, :full_name
  end
end
