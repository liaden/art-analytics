module Unnameable
  extend ActiveSupport::Concern

  included do |base|
    scope :by_name, -> { }
  end
end
