class EventSalesData
  class << self
    def load(data)
      if data.is_a? String
        data = File.open(data, 'r') do |f|
          loader(f)
        end
      else
        loader(data)
      end
    end

    private

    def loader(data)
      h1, h2 = data.readline.split(',')
      data.rewind

      if h1.blank? and h2.blank?
        SalesSpreadsheet.load(data)
      else
        SquareSpreadsheet.load(data)
      end
    end
  end
end
