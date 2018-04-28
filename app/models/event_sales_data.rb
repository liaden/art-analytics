class EventSalesData
  class << self
    def load(data)
      as_io_object(data) do |io|
        sheet_class(io).load(io)
      end
    end

    private

    def as_io_object(filename_or_io)
      if filename_or_io.is_a? String
        File.open(filename_or_io, 'r') do |f|
          yield(f)
        end
      else
        yield(filename_or_io)
      end
    end

    def sheet_class(data)
      h1, h2 = data.readline.split(',')
      data.rewind

      if h1.blank? and h2.blank?
        SalesSpreadsheet
      else
        SquareSpreadsheet
      end
    end
  end
end
