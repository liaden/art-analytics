require 'csv'

class SalesSpreadsheet
  LEADING_COLUMNS = ['total', 'sold on']
  TRAILING_COLUMNS = ['tags']

  class ValidationException < StandardError; end
  class EmptyHeaders < ValidationException; end
  class MismatchedHeaders < ValidationException; end
  class DuplicateHeaderSubheader < ValidationException; end
  class UnexpectedColumn < ValidationException; end
  class BadRow < ValidationException; end

  def self.load(file = 'dummy_file.csv')
    if file.is_a? String
      grid = CSV.read(file)

    else # StringIO or File
      grid = CSV.new(file)
    end

    headers = grid.shift
    subheaders = grid.shift

    new(headers, subheaders, grid)
  end

  attr_reader :headers, :sales_data, :artwork_names, :errors

  def initialize(headers, subheaders, event_data)
    check_empty_headers(headers,subheaders)

    @errors = []
    @sales_data = []

    @artwork_names = headers.compact

    group_headers!(headers, subheaders)
    @expected_row_size = headers.size + LEADING_COLUMNS.size + TRAILING_COLUMNS.size

    event_data.each.with_index do |sale_data, index|
      if @expected_row_size != sale_data.size
        raise BadRow.new("Row #{index} is length of #{sale_data.size} when expecting #{@expected_row_size}")
      end

      raise BadRow.new("On row #{index}: total should not be empty") if sale_data[0].nil?
      raise BadRow.new("On row #{index}: sold on should not be empty") if sale_data[1].nil?

      data = transform_sales_data_to_hash!(sale_data)
      @sales_data << data

      raise BadRow.new("On row #{index}: total should not be negative") if data[:total] < 0
      raise BadRow.new("On row #{index}: sold_on should not be negative") if data[:sold_on] < 0
    end
  end

  def valid?
    return @errors.empty?
  end

  private

  def group_headers!(headers, subheaders)
    LEADING_COLUMNS.each do |leading_column|
      headers.shift

      subheader = subheaders.shift
      if leading_column.to_s != subheader
        raise UnexpectedColumn.new("Expecting column #{leading_column}; got #{subheader}")
      end
    end

    headers.pop
    subheader = subheaders.pop
    if subheader != TRAILING_COLUMNS.last
      raise UnexpectedColumn.new("Expecting column #{TRAILING_COLUMNS.last}; got #{subheader}")
    end

    check_empty_headers(headers, subheaders)

    current_grouping = nil

    @headers = headers.map.with_index do |grouping, index|
      current_grouping = grouping || current_grouping

      [ current_grouping, subheaders[index]]
    end

    raise DuplicateHeaderSubheader.new if @headers.uniq.size != @headers.size
  end

  def transform_sales_data_to_hash!(data)
    hash = { total: data.shift.to_d, sold_on: data.shift.to_i, tags: CSV.parse(data.pop || '').flatten }

    headers.each.with_index do |grouped_header,index|
      header, subheader = *grouped_header

      quantity = data[index].to_i
      raise BadRow.new("On row #{index}: negative quantity is not permitted: #{quantity}") if quantity < 0

      hash[[header,subheader]] = quantity
    end

    hash
  end

  def check_empty_headers(headers, subheaders)
    raise EmptyHeaders.new if headers.empty?
    raise MismatchedHeaders.new if headers.size != subheaders.size
  end
end
