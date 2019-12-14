FactoryBot.define do

  factory :ordered_list_entry do
    name { "OrderedListEntry name" }
    description { "OrderedListEntry description" }
    list_position { 0 }


    # transient allows you to define and pass in variables that are not attributes of this model
    transient do
      num_children { 0 }
      parent_name { '' }
    end

    after(:create) do |ordered_list_entry, evaluator|

      # add child ListEntries if num_children: is given in the call to this factory
      evaluator.num_children.times do |child_num|
        create(:ordered_list_entry, parent: ordered_list_entry, name: "child entry #{child_num}", list_position: child_num)
      end

      # try to look  up the parent if a parent_name was given in the call to this factory
      unless evaluator.parent_name.blank?
        parent = OrderedListEntry.find_by(name: evaluator.parent_name)
        ordered_list_entry.update(parent: parent) if parent
      end
    end

  end

end
