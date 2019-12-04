FactoryBot.define do

  factory :checklist_item do
    name { "Checklist Item name" }
    description { "Checklist Item description" }
    order_in_list { 0 }

    association :checklist
  end

end
