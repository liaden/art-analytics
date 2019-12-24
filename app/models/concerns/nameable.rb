module Nameable
  extend ActiveSupport::Concern

  included do |base|
    if base.attribute_names.include?("full_name")
      base.scope :by_name, -> { order(:full_name) }
    else
      base.scope :by_name, -> { order(:name) }
    end
  end
end
