class ImportSalesController < ApplicationController
  def new
  end

  def create
    begin
      result = ImportSales.run(
        event: event,
        import: create_import,
        dry_run: dry_run,
        spreadsheet: SalesSpreadsheet.load(spreadsheet_file))
    rescue SalesSpreadsheet::ValidationException, Mutations::ValidationException => e
      @errors = [e.message]
      return render 'new'
    end

    if result.success? && params[:confirmed]
      redirect_to events_path(event)
    elsif result.success?
      # dry run
      @new_merchandises = result.result[:new_merchandises]
      @new_artworks = result.result[:new_artworks]
      @sales_data = result.result[:sales_data]

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
    @import ||= Import.create(import_file_data: spreadsheet_file.read).tap do
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
