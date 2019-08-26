# frozen_string_literal: true

# TODO: REFACTOR
# Use Square's API to fetch data in a cleaner fashion
# * remove spreadsheet validations
# * use ActiveRecord's Bulk Import with Rails 6
class ImportSales < Mutations::Command
  required do
    model :spreadsheet, class: EventSalesData
    model :event
    model :import
  end

  optional do
    boolean :dry_run, default: false
    boolean :do_not_overwrite, default: true
  end

  def validate
    if event.sales.any? && do_not_overwrite
      add_error(:event, :existing_data, 'Event already has sales attached to it')
    end

    if !spreadsheet.valid?
      add_eror(:spreadsheet, :file_data, "Bad file data for #{spreadsheet.data_source} spreadsheet")
    end
  end

  def execute
    Event.transaction do
      import_missing_artworks = ImportMissingArtworks.new(names: spreadsheet.artwork_names, import: import)
      @new_artworks           = import_missing_artworks.run!

      import_missing_merchandise = ImportMissingMerchandises.new(
        artworks: artworks.values, import: import,
        merchandise_by_artwork_name: spreadsheet.merchandise_by_artwork_name
      )
      @new_merchandises = import_missing_merchandise.run!

      @artworks = nil

      process_sales

      Sale.import! @sales, recursive: true

      create_event_inventory_list(event, artworks.values.flat_map(&:merchandises))

      raise ActiveRecord::Rollback if dry_run
    end

    { new_merchandises: @new_merchandises, new_artworks: @new_artworks, sales: @sales, inventory_list: @inventory_list }
  end

  private

  def artworks
    @artworks ||= Artwork.includes(:merchandises).where(name: spreadsheet.artwork_names).index_by(&:name)
  end

  def process_sales
    @sales =
      spreadsheet.sales_data.map! do |sale_data|
        attach_merchandise(build_sale(sale_data), sale_data[:merchandise_sold])
      end
  end

  def build_sale(data)
    sold_at = data[:sold_at] || (event.started_at + data[:sold_on].days)

    Sale.new(
      sold_at:                    sold_at,
      sale_price:                 data[:total].to_d,
      tags:                       data[:tags],
      third_party_transaction_id: data[:third_party_transaction_id],
      event:                      event
    )
  end

  def attach_merchandise(record, merchandise_data)
    record.merchandise_sales = merchandise_data.map do |data|
      merch                  = merchandise_lookup(data[:artwork_name], data[:merch_name])

      if data[:quantity] > 0
        MerchandiseSale.new(
          merchandise_id: merch.id,
          quantity:       data[:quantity]
        )
      end
    end.compact

    record
  end

  def merchandise_lookup(art_name, merch_name)
    @merchandise_lookup ||=
      artworks.values
        .each_with_object({}) { |art, hash| hash[art.name] = art.merchandises.index_by(&:name) }
        .tap { |hash| hash['']                             = { '' => Merchandise.unknown_artwork_item } }

    # nil merch_name will convert to an unknown_item
    # nil art_name will  convert to the global unknown_item
    @merchandise_lookup[art_name.to_s][merch_name.to_s]
  end

  def create_event_inventory_list(event, merchandises)
    @inventory_list =
      merchandises.select(&:known_item?).map do |merch|
        EventInventoryItem.new(
          event:       event,
          merchandise: merch
        )
      end
    EventInventoryItem.import @inventory_list, validate: false
  end
end
