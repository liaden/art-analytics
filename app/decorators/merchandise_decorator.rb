class MerchandiseDecorator
  include Haml::Helpers

  def initialize(merchandise)
    @merchnadise = merchandise
  end

  def edit_link(text)
    link_to @merchandise.persisted?, text, edit_merchandise_path(@merchandise)
  end
end
