require 'rails_helper'

RSpec.describe Checklist, type: :model do

  let(:three_completed_two_not_completed_list) { build(:checklist, title: '3 completed 2 not completed_list', num_completed_items: 3, num_not_completed_items: 2) }


  describe 'Factory' do
    it 'has a valid factory' do
      expect(build(:checklist)).to be_valid
      expect(build(:checklist, num_completed_items: 3, num_not_completed_items: 2)).to be_valid
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :title }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:checklist_items) }
  end


  describe 'complete?' do

    it 'false if there are no items (emtpy)' do
      expect(build(:checklist).complete?).to be_falsey
    end

    it 'true if all items are complete' do
      all_complete_list = build(:checklist, title: 'all_completed', num_completed_items: 3)
      expect(all_complete_list.complete?).to be_truthy
    end

    it 'false if 1 or more items are not complete' do
      expect(three_completed_two_not_completed_list.complete?).to be_falsey
    end
  end


  describe 'date_completed' do

    it 'is nil if there are no items (empty)' do
      expect(build(:checklist).date_completed).to be_nil
    end

    it 'is nil if the list is not completed' do
      three_item_checklist = build(:checklist)

      item_1_incomplete = build(:checklist_item, :not_completed)
      three_item_checklist.checklist_items << item_1_incomplete
      item_2_incomplete = build(:checklist_item, :not_completed)
      three_item_checklist.checklist_items << item_2_incomplete
      item_3_incomplete = build(:checklist_item, :not_completed)
      three_item_checklist.checklist_items << item_3_incomplete

      expect(three_item_checklist.date_completed).to be_falsey
    end

    it 'is the latest (last) completed date of all list items' do
      three_item_checklist = build(:checklist)

      item_1_complete = build(:checklist_item, :completed, date_completed: DateTime.new(2020, 11, 11))
      three_item_checklist.checklist_items << item_1_complete
      item_2_complete = build(:checklist_item, :completed, date_completed: DateTime.new(1900, 1, 1))
      three_item_checklist.checklist_items << item_2_complete
      item_3_complete = build(:checklist_item, :completed, date_completed: DateTime.new(2020, 11, 11))
      three_item_checklist.checklist_items << item_3_complete

      expect(three_item_checklist.date_completed).to eq DateTime.new(2020, 11, 11)
    end

  end


  describe 'insert' do

    it 'appends to the end if no index given' do

    end

    it 'calls update_item_order_numbers after item inserted' do

    end
  end


  describe 'delete_by_id' do

    it 'calls delete if the ChecklistItem does exist' do
      newlist = build(:checklist)

      existing_item = create(:checklist_item)
      expect(newlist).to receive(:delete).with(existing_item)

      newlist.delete_by_id(existing_item.id)
    end

    it 'delete is not called (nothing is deleted) if the ChecklistItem does not exist in the db' do
      newlist = build(:checklist)

      expect(ChecklistItem.exists?(999)).to be_falsey # ensure there is not a ChecklistItem with id = 999

      expect(newlist).not_to receive(:delete)

      newlist.delete_by_id(999)
    end
  end


  describe 'delete_by_title' do

    it 'calls delete if the ChecklistItem does exist' do
      newlist = build(:checklist)

      item_title = 'existing_item title'
      existing_item = create(:checklist_item, title: item_title)
      expect(newlist).to receive(:delete).with(existing_item)

      newlist.delete_by_title(item_title)
    end

    it 'delete is not called (nothing is deleted) if the ChecklistItem does not exist in the db' do
      newlist = build(:checklist)

      temp_title = "title-#{Time.now.to_i}"
      expect(ChecklistItem.exists?(title: temp_title)).to be_falsey # ensure there is not a ChecklistItem with this title

      expect(newlist).not_to receive(:delete)

      newlist.delete_by_title(temp_title)
    end
  end


  describe 'delete' do

    it 'deletes the item from checklist_items' do
      newlist = build(:checklist, num_completed_items: 1)
      newlist.delete(newlist.checklist_items.first)
      expect(newlist.checklist_items).to be_empty
    end

    it 'calls update_item_order_numbers after item deleted if item was in the checklist' do
      newlist = build(:checklist, num_completed_items: 2)
      expect(newlist).to receive(:update_item_order_numbers)

      last_item = newlist.checklist_items.last
      newlist.delete(last_item)
    end

    it 'does not call update_item_order_numbers if item is not in the checklist' do
      newlist = build(:checklist)
      expect(newlist).not_to receive(:update_item_order_numbers)
      some_item = build(:checklist_item)
      newlist.delete(some_item)
    end
  end


  describe 'completed_items' do

    it 'empty list if checklist_items is emmpty' do
      expect(build(:checklist).completed_items).to be_empty
    end


    it 'returns a list of all items that are completed, in their order' do
      expect(three_completed_two_not_completed_list.completed_items.map(&:title)).to match_array(["checklist item completed 0", "checklist item completed 1", "checklist item completed 2"])
    end
  end


  describe 'not_completed_items' do

    it 'returns a list of all items NOT completed, in their order' do
      expect(three_completed_two_not_completed_list.not_completed_items.map(&:title)).to match_array(["checklist item not complete 0", "checklist item not complete 1"])
    end

  end


  describe 'checklist can be nested (hold other checklists)' do
    skip 'This can be implemented at a later time.'
  end

end
