FactoryBot.define do

  factory :checklist do
    name { "Checklist name" }
    description { "Checklist description" }
    checklist_items { [] }


    # transient allows you to define and pass in variables that are not attributes of this model
    transient do
      num_items { 0 }
    end

    after(:build) do |checklist, evaluator|

      # add checklist_items if num_items: is given in the call to this factory
      evaluator.num_items.times do |items_num|
        checklist.checklist_items << build(:checklist_item, checklist: checklist, name: "checklist item #{items_num}")
      end
    end

  end

end
