# frozen_string_literal: true

FactoryBot.define do
  factory :import do
    note { "test note" }
    import_file_data { "this is junk data" }
  end
end
