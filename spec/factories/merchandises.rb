FactoryGirl.define do
  factory :merchandise do
    name 'canvas_print'
    tags ['12x18', 'canvas']
    artwork { create(:artwork) }
  end
end