FactoryGirl.define do
  factory :merchandise_sale do
    quantity 1
    merchandise { create(:merchandise) }
  end
end
