require 'rails_helper'

RSpec.describe UserChecklist, type: :model do

  describe 'Factory' do

    it 'has a valid factory' do
      expect(build(:user_checklist)).to be_valid
    end
  end


  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:checklist) }
  end

  describe 'Scope' do

    describe 'completed' do
      pending
    end

    describe 'not_completed' do
      pending
    end
  end


  describe 'completed?' do

    it 'false if there are no items (emtpy)' do
      expect(build(:user_checklist).completed?).to be_falsey
    end

    it 'true if all items are complete' do
      #all_complete_list = build(:user_checklist, name: 'all_completed', num_completed_items: 3)
      #expect(all_complete_list.completed?).to be_truthy
      pending
    end

    it 'false if 1 or more items are not complete' do
      #expect(three_completed_two_not_completed_list.completed?).to be_falsey
      pending
    end
  end


  describe 'time_completed' do

    let(:user) { create(:user) }


    it 'is nil if there are no items (empty)' do
      expect(build(:user_checklist).time_completed).to be_nil
    end

    it 'is nil if the list is not completed' do
      three_item_checklist = build(:user_checklist)

      #item_1_incomplete = build(:user_checklist_item, :not_completed, user: user)
      #three_item_checklist.checklist_items << item_1_incomplete
      #item_2_incomplete = build(:user_checklist_item, :not_completed)
      #three_item_checklist.checklist_items << item_2_incomplete
      #item_3_incomplete = build(:user_checklist_item, :not_completed)
      #three_item_checklist.checklist_items << item_3_incomplete

      expect(three_item_checklist.time_completed).to be_falsey

    end

    it 'is the latest (last) completed date of all list items' do
      three_item_checklist = build(:user_checklist)

      #item_1_complete = build(:user_checklist_item, :completed, time_completed: DateTime.new(2020, 11, 11))
      #three_item_checklist.checklist_items << item_1_complete
      #
      #item_2_complete = build(:user_checklist_item, :completed, time_completed: DateTime.new(1900, 1, 1))
      #three_item_checklist.checklist_items << item_2_complete
      #
      #item_3_complete = build(:user_checklist_item, :completed, time_completed: DateTime.new(2020, 11, 11))
      #three_item_checklist.checklist_items << item_3_complete
      #
      #expect(three_item_checklist.time_completed).to eq DateTime.new(2020, 11, 11)
    end

  end


  let(:five_item_checklist) { build(:checklist, name: '5 items checklist')}

  let(:five_item_user_checklist) { build(:user_checklist, checklist: five_item_checklist, user: user )}

  describe 'completed_items' do

    it 'empty list if checklist_items is emmpty' do
      #expect(build(:checklist).completed_items).to be_empty
      pending
    end


    it 'returns a list of all items that are completed, in their order' do
      #expect(three_completed_two_not_completed_list.completed_items.map(&:name)).to match_array(["checklist item completed 0", "checklist item completed 1", "checklist item completed 2"])
      pending
    end
  end


  describe 'not_completed_items' do

    let(:three_completed_two_not_completed_list) { build(:user_checklist, name: '3 completed 2 not completed_list', num_completed_items: 3, num_not_completed_items: 2) }

    it 'returns a list of all items NOT completed, in their order' do
      #expect(three_completed_two_not_completed_list.not_completed_items.map(&:name)).to match_array(["checklist item not complete 0", "checklist item not complete 1"])
      pending
    end

  end


end
