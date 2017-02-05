require 'csv'

class SquareSpreadsheet < EventSalesData
  class CsvFormatError < StandardError; attr_accessor :csv_line_num; end
  class AmbiguousMerchandiseQuantities < CsvFormatError; end
  class AmbiguousMerchandise < StandardError; end

  attr_reader :errors, :sales_data

  def initialize(data)
    # start at 1 due to headers
    @csv_line_num = 1
    @errors = []
    @refunded_transactions = Set.new

    @sales_data = data.map do |line|
      process(line) unless skip?(line)
    end.compact
  end

  def self.load(file = 'dummy_square.csv')
    options = {
      headers: true,
      header_converters: :symbol,
    }

    if file.is_a? String
      grid = CSV.read(file, options)

    else # StringIO or File
      grid = CSV.new(file, options)
    end

    new(grid)
  end

  def process(line)
    @csv_line_num += 1

    sale = line.to_hash

    {
      total: Monetize.parse(sale[:total_collected]),
      discounts: Monetize.parse(sale[:discounts]),
      tax: Monetize.parse(sale[:tax]),
      processing_fees: Monetize.parse(sale[:fees]),
      time_zone: sale[:time_zone],
      sold_at: sold_at(sale[:date], sale[:time], sale[:time_zone]),
      time: ActiveSupport::TimeZone[sale[:time_zone]].parse(sale[:time]),
      merchandise_sold: parse_sale(sale[:description]),
      third_party_transaction_id: "SQUARE::#{sale[:transaction_id]}",
      tags: []
    }

  rescue CsvFormatError => e
    e.csv_line = @csv_line_num
    @errors << e
  end

  def valid?
    @errors.empty?
  end

  def artwork_names
    @sales_data.flat_map do |sale|
      sale[:merchandise_sold].map { |merch| merch[:artwork_name] }
    end.uniq
  end

  def merchandise_by_artwork_name
    result = Hash.new { |h, k| h[k] = [] }

    @sales_data.
      flat_map { |sale| sale[:merchandise_sold] }.
      map { |merch_sold| result[merch_sold[:artwork_name]] << merch_sold[:merch_name] }

    result.delete("")

    result
  end

  def data_source
    'square'
  end

  def self.parse_merchandise_name(item)
    matches = item.match(/.*[(]([ a-zA-Z0-9]+)\s*[)]$/)
    return nil if matches.nil?

    matches[1].strip
  end

  private

  def skip?(line)
    if line[:event_type].downcase == 'refund'
      @refunded_transactions << line[:transaction_id]
      true
    elsif @refunded_transactions.member?(line[:transaction_id])
      true
    else
      false
    end
  end

  def parse_sale(merchandise)
    return [
      { quantity: 1,
        artwork_name: Merchandise.unknown_artwork_item.name }
    ] if merchandise == 'Custom Amount'

    merchandise.split(',').map do |item|
      {
        quantity: parse_quantity(item),
        artwork_name: parse_artwork_name(item),
        merch_name: SquareSpreadsheet.parse_merchandise_name(item)
      }
    end
  end

  def parse_artwork_name(item)
    item.rpartition('(').first.strip!
  end

  def parse_quantity(item)
    regex = /^(\d+) x /
    matches = item.scan(regex)

    raise AmbiguousMerchandiseQuantities.new(item) if matches.size > 1
    return 1 if matches.empty?

    item.gsub!(regex, '')
    Integer(matches[0].first)
  end

  def sold_at(date, time, timezone)
    ActiveSupport::TimeZone[timezone].parse(time, Date.strptime(date, '%m/%d/%y')).to_datetime
  end
end

