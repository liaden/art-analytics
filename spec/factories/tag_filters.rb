FactoryBot.define do
  factory :tag_filter do
    trait(:matches_all)  { matching_mechanism :all }
    trait(:matches_some) { matching_mechanism :some }
    trait(:matches_none) { matching_mechanism :none }

    trait(:prepend_and) { prepend_with :and }
    trait(:prepend_or)  { prepend_with :or }
    trait(:prepend_not) { prepend_with :not }
  end
end
