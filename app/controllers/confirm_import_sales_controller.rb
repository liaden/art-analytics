class ConfirmImportSalesController < ApplicationController
  def create
    @import = Import.find(params[:import_id])
    result = ImportSales.run(event: event, import: @import, spreadsheet: SalesSpreadsheet.load(spreadsheet_file), dry_run: false)

    if result.success?
      redirect_to events_path(event)
    else
      # this shouldn't happen since it was successful to get here

      @import.destroy
      redirect_to new_import_sales_path
    end
  end

  private

  def event
    @event = Event.find(params[:event_id])
  end

  def import
    @import = Import.find(params[:import_id])
  end

  def spreadsheet_file
    StringIO.new(@import.import_file_data)
  end
end
