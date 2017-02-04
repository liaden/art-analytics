def headers(columns)
  SalesSpreadsheet::LEADING_COLUMNS.map() { nil } + columns + SalesSpreadsheet::TRAILING_COLUMNS.map() { nil }
end

def subheaders(columns)
  SalesSpreadsheet::LEADING_COLUMNS + columns + SalesSpreadsheet::TRAILING_COLUMNS
end

def empty_spreadsheet(extra_headers, extra_subheaders)
  SalesSpreadsheet.new(headers(extra_headers), subheaders(extra_subheaders), [])
end

def make_spreadsheet(extra_headers, extra_subheaders, sales_transactions)
  subheaders = subheaders(extra_subheaders)
  headers = headers(extra_headers)
  zipped = headers.zip(subheaders)

  sales = sales_transactions.map do |sale|
    zipped.map do |pair|
      sale = {'sold on' => 0 }.merge(sale)
      sale[pair] || sale[pair.compact.first.to_s]
    end
  end

  SalesSpreadsheet.new(headers, subheaders, sales)
end