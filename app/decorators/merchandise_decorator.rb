# frozen_string_literal: true

class MerchandiseDecorator
  # include Haml::Helpers

  def initialize(merchandise)
    @merchandise = merchandise
  end

  def edit_link(text)
    link_to @merchandise.persisted?, text, edit_merchandise_path(@merchandise)
  end

  def full_name
    "#{@merchandise.artwork.name} #{@merchandise.name}"
  end
end
