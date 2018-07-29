FactoryBot.define do
  factory :merchandise_sale do
    quantity 1
    merchandise { create(:merchandise) }
    sale { create(:sale) }
  end
end
