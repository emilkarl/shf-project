FactoryBot.define do

  factory :checklist do
    title { "Checklist title" }
    description { "Checklist description" }
    checklist_items { [] }


    # transient allows you to define and pass in variables that are not attributes of this model
    transient do
      num_completed_items { 0 }
      num_not_completed_items { 0 }
    end


    after(:build) do |checklist, evaluator|

      # add completed checklist_items if num_completed_items:  is given in the call to this factory
      evaluator.num_completed_items.times do |items_num|
        checklist.checklist_items << build(:checklist_item, :completed, checklist: checklist, title: "checklist item completed #{items_num}")
      end

      # add not completed checklist_items if num_not_completed_items:  is given in the call to this factory
      evaluator.num_not_completed_items.times do |items_num|
        checklist.checklist_items << build(:checklist_item, :not_completed, checklist: checklist, title: "checklist item not complete #{items_num}")
      end
    end

  end

end
