require 'rails_helper'

RSpec.describe Checklist, type: :model do

  #let(:three_completed_two_not_completed_list) { build(:checklist, name: '3 completed 2 not completed_list', num_completed_items: 3, num_not_completed_items: 2) }
  #let(:three_items_list) { build(:checklist, name: '3 items list', num_items: 3) }

  describe 'Factory' do
    it 'has a valid factory' do
      expect(build(:checklist)).to be_valid
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:checklist_items) }
  end


  describe 'insert' do

    it 'appends to the end if no index given' do
      pending
    end

    it 'calls update_item_order_numbers after item inserted' do
      newlist = build(:checklist, num_items: 2)
      expect(newlist).to receive(:update_item_order_numbers)

      new_item = build(:checklist_item, checklist: newlist)
      newlist.insert(new_item)
    end

    it 'order in list is correct for all items' do
      pending
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


  describe 'delete' do

    it 'deletes the item from checklist_items' do
      newlist = build(:checklist, num_items: 1)
      newlist.delete(newlist.checklist_items.first)
      expect(newlist.checklist_items).to be_empty
    end

    it 'calls update_item_order_numbers after item deleted if item was in the checklist' do
      newlist = build(:checklist, num_items: 2)
      expect(newlist).to receive(:update_item_order_numbers)

      last_item = newlist.checklist_items.last
      newlist.delete(last_item)
    end


    it 'order in list is correct for all items' do
      pending
    end


    it 'does not call update_item_order_numbers if item is not in the checklist' do
      newlist = build(:checklist)
      expect(newlist).not_to receive(:update_item_order_numbers)
      some_item = build(:checklist_item)
      newlist.delete(some_item)
    end
  end


  describe 'checklist can be nested (hold other checklists)' do
    pending
  end

end
