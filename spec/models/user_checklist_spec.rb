require 'rails_helper'

RSpec.describe UserChecklist, type: :model do

  let(:all_complete_list) { create(:user_checklist, :completed, num_completed_children: 3) }

  let(:three_complete_two_uncomplete_list) {
    checklist_3done_2unfinished = create(:user_checklist, :completed, num_completed_children: 2)
    list_user = checklist_3done_2unfinished.user

    last_item = checklist_3done_2unfinished.children.last
    not_complete1 = create(:user_checklist, user: list_user, list_position: 200, parent: not_complete1)
    last_item.insert(not_complete1)

    not_complete1_child1 = create(:user_checklist, user: list_user, list_position: 201, parent: not_complete1)
    not_complete1.insert(not_complete1_child1)
    checklist_3done_2unfinished
  }


  describe 'Factory' do

    it 'default factory is valid' do
      expect(build(:user_checklist)).to be_valid
    end

    it 'traits are valid' do
      expect(create(:user_checklist, :completed)).to be_valid
    end

    it 'arguments passed in are valid' do
      parent_item = create(:user_checklist)

      expect(build(:user_checklist, parent: parent_item)).to be_valid
      expect(create(:user_checklist, num_children: 3)).to be_valid
      expect(create(:user_checklist, num_completed_children: 2)).to be_valid

      expect(create(:user_checklist, parent: parent_item, num_children: 2, num_completed_children: 3)).to be_valid
    end
  end


  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:checklist) }
  end


  describe 'Scopes (including those as class methods)' do

    describe 'completed' do
      it 'empty if no UserChecklist is completed' do
        create(:user_checklist)
        expect(described_class.completed).to be_empty
      end

      it 'all where date_completed is NOT NULL (not nil)' do
        3.times { create(:user_checklist, :completed) }
        create(:user_checklist)
        expect(described_class.completed.count).to eq 3
      end
    end

    describe 'uncompleted' do
      it 'empty if all UserChecklists are completed' do
        create(:user_checklist, :completed)
        expect(described_class.uncompleted).to be_empty
      end

      it 'all where date_completed is NULL (nil)' do
        3.times { create(:user_checklist) }
        create(:user_checklist, :completed)
        expect(described_class.uncompleted.count).to eq 3
      end
    end

    it 'completed_by_user' do
      checklist_1 =  create(:user_checklist, :completed)
      user_1 = checklist_1.user
      2.times { create(:user_checklist, :completed, user: user_1) }

      create(:user_checklist, :completed)

      expect(described_class.completed_by_user(user_1).count).to eq 3
    end

    it 'not_completed_by_user' do
      checklist_1 =  create(:user_checklist)
      user_1 = checklist_1.user
      2.times { create(:user_checklist, user: user_1) }

      create(:user_checklist, :completed, user: user_1)

      2.times { create(:user_checklist, :completed) }

      expect(described_class.not_completed_by_user(user_1).count).to eq 3
    end
  end


  describe 'completed?' do

    it 'false if self is not completed' do
      expect(build(:user_checklist).completed?).to be_falsey
    end

    it 'true if self and all children are complete' do
      all_complete_list = create(:user_checklist, :completed, num_completed_children: 3)
      expect(all_complete_list.completed?).to be_truthy
    end

    it 'false if 1 or more children are not complete' do
      expect(three_complete_two_uncomplete_list.completed?).to be_falsey
    end
  end


  describe 'completed' do

    it 'empty list if no items are complete' do
      expect(create(:user_checklist).completed).to be_empty
    end

    it 'returns a list of all items that are completed, including descendents, in order by list_position' do
      result = three_complete_two_uncomplete_list.completed

      expect(result).to include(three_complete_two_uncomplete_list) # includes the root of the tree
      expect(result).to include(three_complete_two_uncomplete_list.children.first)
      expect(result).to include(three_complete_two_uncomplete_list.children.last)
      expect(result).not_to include(three_complete_two_uncomplete_list.children.last.children.first)
      expect(result).not_to include(three_complete_two_uncomplete_list.children.last.children.last)

      result_list_positions = result.map(&:list_position)
      expect(result_list_positions).to match_array([0, 0, 1])
    end
  end


  describe 'uncompleted' do

    it 'empty list if all items are completed' do
      all_complete = create(:user_checklist, :completed, num_completed_children: 1)
      expect(all_complete.uncompleted).to be_empty
    end

    it 'returns a list of all items NOT completed, including descendents, in order by list_position' do
      undone_root = create(:user_checklist)
      list_user = undone_root.user
      done_item = create(:user_checklist, :completed, user: list_user, list_position: 9, parent: undone_root)
      done_sub1_not_complete = create(:user_checklist, user: list_user, list_position: 5, parent: done_item)

      result = undone_root.uncompleted

      expect(result).to include(undone_root)
      expect(result).to include(done_sub1_not_complete)
      expect(result).not_to include(done_item)

      result_list_positions = result.map(&:list_position)
      expect(result_list_positions).to match_array([0, 5])
    end
  end


  it 'size = completed items + uncompleted items' do
    expect(three_complete_two_uncomplete_list.completed.size + three_complete_two_uncomplete_list.uncompleted.size).to eq(5)
  end
end
