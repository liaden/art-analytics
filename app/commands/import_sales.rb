class ImportSales < Mutations::Command
  required do
    model :spreadsheet, class: SalesSpreadsheet
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
      add_eror(:spreadsheet, :file_data, 'Bad file data for sales spreadsheet')
    end
  end

  def execute
    Event.transaction do

      import_missing_artworks = ImportMissingArtworks.new(names: spreadsheet.artwork_names, import: import)
      @new_artworks = import_missing_artworks.run!

      import_missing_merchandise = ImportMissingMerchandises.new(artworks: artworks.values, import: import,  merchandise_by_artwork_name: spreadsheet_merchandise_by_artwork_name)
      @new_merchandises = import_missing_merchandise.run!

      @artworks = nil

      @sales = spreadsheet.sales_data.map do |sale_data|
        attach_merchandise(build_sale(sale_data), sale_data[:merchandise_sold])
      end

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

  def spreadsheet_merchandise_by_artwork_name
    spreadsheet.headers.reduce(Hash.new { |h, k| h[k] = [] }) do |hash, header_pair|
      hash[header_pair[0]] << header_pair[1]
      hash
    end
  end

  def build_sale(data)
    Sale.new(
      sold_on: event.started_at + data[:sold_on].days,
      sale_price: BigDecimal.new(data[:total]),
      tags: data[:tags],
      event: event
    )
  end

  def attach_merchandise(record, merchandise_data)
    record.merchandise_sales = merchandise_data.map do |data|
      merch = merchandise_lookup(data[:artwork_name], data[:merch_name])

      if data[:quantity] > 0
        MerchandiseSale.new(
          merchandise_id: merch.id,
          quantity: data[:quantity]
        )
      end
    end.compact

    record
  end

  def merchandise_lookup(art_name, merch_name)
    @merchandise_lookup ||= artworks.values.each_with_object({}) { |art, hash| hash[art.name] = art.merchandises.index_by(&:name) }
    @merchandise_lookup[art_name][merch_name]
  end

  def create_event_inventory_list(event, merchandises)
    @inventory_list = merchandises.map { |merch| EventInventoryItem.new(event: event, merchandise: merch) }
    EventInventoryItem.import @inventory_list, validate: false
  end
end
