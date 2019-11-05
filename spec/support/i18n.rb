module LoadI18n
  def with_translations(data)
    if data.is_a?(Symbol)
      before { I18n.backend.store_translations(:en, send(data)) }
    else
      before { I18n.backend.store_translations(:en, data) }
    end

    after { I18n.backend.reload! }
  end
end

RSpec.configure { |c| c.extend(LoadI18n) }
