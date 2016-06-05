FactoryGirl.define do
  factory :purchase do
    sale_price 2500
    list_price 2500
    sold_on "2016-06-05"
    note "MyText"
    merchandises { [create(:merchandise)] }
  end
end
