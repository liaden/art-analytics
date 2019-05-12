# frozen_string_literal: true

class Dimension < ApplicationRecord
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :thickness, numericality: { greater_than_or_equal_to: 0 }

  has_many :merchandises

  def landscape?
    width > height && !square?
  end

  def portrait?
    height > width && !square?
  end

  def square?
    height == width
  end
end
