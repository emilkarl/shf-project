require 'rails_helper'


RSpec.describe OrderedListEntry do


  describe 'increment_child_positions' do

    it 'empty list' do
      empty_list = create(:ordered_list_entry)
      expect(empty_list.children.map(&:list_position)).to match_array([])

      empty_list.send(:increment_child_positions, 0)
      expect(empty_list.children.map(&:list_position)).to match_array([])
    end


    context 'not an empty list' do

      it 'at the start' do
        list_5_kids = create(:ordered_list_entry, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:increment_child_positions, 0)
        expect(list_5_kids.children.map(&:list_position)).to match_array([1, 2, 3, 4, 5])
      end

      it 'in the middle' do
        list_5_kids = create(:ordered_list_entry, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:increment_child_positions, 2)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 3, 4, 5])
      end

      it 'at the end' do
        list_5_kids = create(:ordered_list_entry, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:increment_child_positions, 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])
      end
    end
  end


  describe 'decrement_child_positions' do

    it 'empty list' do
      empty_list = create(:ordered_list_entry)
      expect(empty_list.children.map(&:list_position)).to match_array([])

      empty_list.send(:decrement_child_positions, 0)
      expect(empty_list.children.map(&:list_position)).to match_array([])
    end


    context 'not an empty list' do

      it 'at the start - will not decrement 0' do
        list_5_kids = create(:ordered_list_entry, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:decrement_child_positions, 0)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 0, 1, 2, 3])
      end

      it 'in the middle' do
        list_5_kids = create(:ordered_list_entry, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:decrement_child_positions, 2)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 1, 2, 3])
      end

      it 'at the end' do
        list_5_kids = create(:ordered_list_entry, num_children: 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])

        list_5_kids.send(:decrement_child_positions, 5)
        expect(list_5_kids.children.map(&:list_position)).to match_array([0, 1, 2, 3, 4])
      end
    end
  end


  describe 'insert' do

    it 'appends to the end if no index given' do
      newlist = create(:ordered_list_entry, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).and_call_original

      new_item = create(:ordered_list_entry)
      newlist.insert(new_item)

      expect(newlist.children.size).to eq 3
      expect(new_item.list_position).to eq 2
    end

    it 'calls increment_child_positions after item inserted and updated positions are correct' do
      newlist = create(:ordered_list_entry, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).and_call_original

      new_item = create(:ordered_list_entry)
      newlist.insert(new_item, 1)

      expect(newlist.children.size).to eq 3
      expect(new_item.list_position).to eq 1
      expect(newlist.children.map(&:list_position)).to match_array([0, 1, 2])
    end

  end


  describe 'delete' do

    it 'deletes the item from list_entry_items' do
      newlist = create(:ordered_list_entry, num_children: 1)
      newlist.delete(newlist.children.first)
      expect(newlist.children).to be_empty
    end

    it 'calls decrement_child_positions after item deleted if item was in the list_entry' do
      newlist = create(:ordered_list_entry, num_children: 3)
      expect(newlist).to receive(:decrement_child_positions).and_call_original

      last_item = newlist.children.last
      newlist.delete(last_item)

      expect(newlist.children.size).to eq 2
      expect(newlist.children.map(&:list_position)).to match_array([0, 1])
    end

  end


  it 'list_entry can hold other list_entries (be nested)' do
    toplist = create(:ordered_list_entry, name: 'toplist', num_children: 3)
    level2_1_list = create(:ordered_list_entry, name: 'level2_1_list', num_children: 2)
    level2_2_list = create(:ordered_list_entry, name: 'level2_2_list', num_children: 1)
    level3_1_list = create(:ordered_list_entry, name: 'level3_1_list', num_children: 1)

    level2_1_list.insert(level3_1_list)
    toplist.insert(level2_1_list)
    toplist.insert(level2_2_list, 1)

    expect(level2_1_list.children.size).to eq 3
    expect(level2_2_list.list_position).to eq 1
    expect(level2_1_list.children.map(&:name)).to match_array(['child entry 0', 'child entry 1', 'level3_1_list'])

    expect(toplist.children.size).to eq 5
    expect(toplist.children.map(&:name)).to match_array(['child entry 0', 'child entry 1', 'child entry 2', 'level2_1_list', 'level2_2_list'])
  end

end
