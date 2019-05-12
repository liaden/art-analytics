# frozen_string_literal: true

class Import < ApplicationRecord
  has_one :event

  has_many :merchandises
  has_many :artworks

  validates :import_file_data, presence: true
end
