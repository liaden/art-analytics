FactoryGirl.define do
  factory :event do
    name "MyString"
    started_at { Date.today }
    ended_at { Date.tomorrow }
    tags ""
  end
end
