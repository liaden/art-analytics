# frozen_string_literal: true

class MerchandiseDecorator < BaseDecorator
  def edit_link(text)
    link_to @object.persisted?, text, edit_merchandise_path(@object)
  end

  def full_name
    "#{@object.artwork.name} #{@object.name}"
  end
end
