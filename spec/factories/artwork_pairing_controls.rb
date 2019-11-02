# frozen_string_literal: true

FactoryBot.define do
  factory :artwork_pairing_controls do
    minimum_pairing_frequency { 1 }
  end
end
