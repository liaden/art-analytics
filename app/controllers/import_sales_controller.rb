# frozen_string_literal: true

#
# TODO: DELETE AND REPLACE
# Use my square-lite gem to hit Square's API instead of importing via a CSV file
#   Square's API exposes a cleaner interface into the data rather than having to split strings all over
#
class ImportSalesController < ApplicationController
  def new
  end

  def create
    begin
      result = ImportSales.run(
        event:       event,
        import:      create_import,
        dry_run:     dry_run,
        spreadsheet: EventSalesData.load(spreadsheet_file))
    rescue SalesSpreadsheet::ValidationException, Mutations::ValidationException => e
      @errors = [e.message]
      return render 'new'
    end

    if result.success? && params[:confirmed]
      redirect_to events_path(event)
    elsif result.success?
      # dry run
      @new_merchandises = result.result[:new_merchandises]
      @new_artworks     = result.result[:new_artworks]
      @sales_data       = result.result[:sales_data]
      @inventory_list   = result.result[:inventory_list]

      render 'confirm_import_sales/new'
    else
      @errors = result.errors.message_list
      render 'new'
    end
  end

  private

  def event
    @event ||= Event.find(params[:event_id])
  end

  def create_import
    @import ||=
      Import.create(import_file_data: spreadsheet_file.read).tap do
        spreadsheet_file.seek(0)
      end
  end

  def spreadsheet_file
    Rails.logger.debug params.inspect
    params[:spreadsheet].tempfile
  end

  def dry_run
    params[:confirmed] != true
  end
end
