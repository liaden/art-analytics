class TagifyCleaner
  def initialize(params)
    @params = params
  end

  def process!(*keypath)
    cd_keypath(*keypath) do |data|
      if data.blank?
        ''
      else
        JSON.parse(data).map! { |item| item['value'] }
      end
    end
  end

  private

  def cd_keypath(*keypath)
    tag_attr = keypath.pop

    hash = keypath.empty? ? @params : @params.dig(*keypath)
    data = hash[tag_attr]

    hash[tag_attr] = yield data
  end
end
