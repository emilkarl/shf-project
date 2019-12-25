require 'rails_helper'


RSpec.describe ChecklistManager do


  describe ".create_list_for_user(list, user)" do

    it 'returns [] if the list is nil' do
      expect(described_class.create_list_for_user(nil, create(:user))).to match_array([])
    end

    it 'returns [] if user is nil' do
      expect(described_class.create_list_for_user([create(:ordered_list_entry)], nil)).to match_array([])
    end

    it 'creates 1 UserChecklist for an OrderedEntry with no children' do
      user = create(:user)
      orig_list = create(:ordered_list_entry, name: 'top item') # have to use create instead of build so that the ancestry gem will generate the ancestry attribute required

      user_checklist = described_class.create_list_for_user([orig_list], user)

      expect(user_checklist.size).to eq 1
      expect(user_checklist.first.user).to eq user
      expect(user_checklist.first.checklist).to eq(orig_list)
    end

    it 'creates an ordered list of UserChecklists for an OrderedEntry with children' do
      user = create(:user)
      item1_top_list = OrderedListEntry.create(name: 'item1 top_list', list_position: 0)
      item2_top_list = OrderedListEntry.create(name: 'item2 top_list', list_position: 1)
      OrderedListEntry.create(name: 'item1 sublist_1', list_position: 10, parent: item2_top_list)
      item2_sublist_1 = OrderedListEntry.create(name: 'item2 sublist_1', list_position: 11, parent: item2_top_list)
      OrderedListEntry.create(name: 'item1 sublist_1_1', list_position: 110, parent: item2_sublist_1)

      list_of_items = [item1_top_list, item2_top_list]
      user_checklist = described_class.create_list_for_user(list_of_items, user)

      expect(user_checklist.size).to eq 5
      expect(user_checklist.first.user).to eq user
      expect(user_checklist.first.checklist).to eq(item1_top_list)
      expect(user_checklist.map(&:list_position)).to match_array([0, 1, 10, 11, 110])
    end

  end

end
