module TagifyCleaner
  def self.process(data)
    JSON.parse(data).map! { |item| item['value'] }
  end
end
