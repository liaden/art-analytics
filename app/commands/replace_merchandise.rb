# frozen_string_literal: true

class ReplaceMerchandise < Mutations::Command
  required do
    model :replacee, class: ActiveRecord::Base
    model :replacer, class: ActiveRecord::Base
  end

  def execute
    handle_collision

    if replacer.dimension.nil? and replacee.dimension.present?
      replacer.dimension = replacee.dimension
    end

    ReplaceModel.run!(
      replacee:       replacee,
      replacer:       replacer,
      related_tables: [MerchandiseSale, EventInventoryItem],
      destroy:        true
    )
  end

  def handle_collision
    # handle replacee and replacer both being at an event

    replacees_events = replacee.event_inventory_items
    replacers_events = replacer.event_inventory_items.index_by(&:event_id)

    replacees_events.each do |replacees_event|
      if replacers_event = replacers_events[replacees_event.event_id]
        replacees_event.destroy
      end
    end
  end
end
