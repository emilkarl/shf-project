FactoryBot.define do

  factory :checklist_item do
    title { "Item title" }
    description { "Item description" }
    complete { false }
    date_completed { nil }
    order_in_list { 0 }

    association :checklist
  end

  trait(:completed) do
    complete { true }
    date_completed { "2019-11-14 12:53:34" }
  end

  trait(:not_completed) do
    complete { false }
    date_completed { nil }
  end

end
