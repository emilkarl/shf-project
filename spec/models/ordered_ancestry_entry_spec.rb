require 'rails_helper'

# OrderedAncestryEntry is a module and so cannot be instantiated.
# OrderedListEntry includes it and so is used to test the class.
#
RSpec.describe "module OrderedAncestryEntry" do

  let(:class_that_includes) { OrderedListEntry }


  let(:child_one) { create(:ordered_list_entry, name: 'child 1') }
  let(:child_two) { create(:ordered_list_entry, name: 'child 2') }
  let(:child_three) { create(:ordered_list_entry, name: 'child 3') }

  let(:two_children) do
    list = create(:ordered_list_entry, name: 'two children')
    list.insert(child_one)
    list.insert(child_two)
    list
  end

  let(:three_children) do
    list = create(:ordered_list_entry, name: 'three children')
    list.insert(child_one)
    list.insert(child_two)
    list.insert(child_three)
    list
  end


  describe 'all_as_array' do
    it "calls arrange_as_array with the order [ancestry, list_position]" do
      expect(class_that_includes).to receive(:arrange_as_array).with(order: %w(ancestry list_position))
      class_that_includes.all_as_array
    end

    it 'concats any additional order attributes to the defaults' do
      expect(class_that_includes).to receive(:arrange_as_array).with(order: %w(ancestry list_position one two three))
      class_that_includes.all_as_array(order: ['one', 'two', 'three'])
    end
  end


  describe 'arrange_as_array(options = {}, nodes_to_arrange_hash = nil)' do

    it 'if no nodes_to_arrange_hash is given, calls arrange to create the hash of nodes' do
      expect(class_that_includes).to receive(:arrange).and_call_original
      class_that_includes.arrange_as_array
    end


    it 'uses the hash of nodes given' do
      entry1 = create(:ordered_list_entry, name: 'entry1')
      two_children = create(:ordered_list_entry, name: '1 child')
      two_children.insert(entry1)

      given_hash = { two_children: { entry1: {} } }

      class_that_includes.arrange_as_array({}, given_hash)
    end

    it 'returns an Array just with the entry if entry has no chidren' do
      no_children = create(:ordered_list_entry)
      expect(class_that_includes.arrange_as_array).to match_array([no_children])
    end

    it 'calls arrange_as_array for all children of each node' do
      create(:ordered_list_entry, num_children: 2)
      expect(class_that_includes).to receive(:arrange_as_array).exactly(4).times.and_call_original
      class_that_includes.arrange_as_array
    end

    it 'adds the entry and its children (arranged as an array) to the array returned' do
      two_children_list = create(:ordered_list_entry, name: 'two_children_list')
      first_child = create(:ordered_list_entry, name: 'first_child')
      second_child_child = create(:ordered_list_entry, name: 'second_child_child')
      second_child = create(:ordered_list_entry, name: 'second_child')
      second_child.insert(second_child_child)
      two_children_list.insert(first_child)
      two_children_list.insert(second_child)

      expect(class_that_includes.arrange_as_array).to eq([two_children_list,
                                                      first_child,
                                                      second_child,
                                                      second_child_child])
    end
  end


  describe 'insert' do

    it 'appends to the end if no position given' do
      newlist = create(:ordered_list_entry, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).and_call_original

      new_entry = create(:ordered_list_entry)
      newlist.insert(new_entry)

      expect(newlist.children.size).to eq 3
      expect(new_entry.list_position).to eq 2
    end

    it 'calls increment_child_positions for entries that come after this list position' do
      newlist = create(:ordered_list_entry, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).with(1).and_call_original

      newlist.insert(create(:ordered_list_entry), 1)
    end

    it 'updates the list_position and the parent for the entry' do
      newlist = create(:ordered_list_entry, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).and_call_original

      new_entry = create(:ordered_list_entry)
      newlist.insert(new_entry, 1)

      expect(new_entry.list_position).to eq 1
      expect(new_entry.parent).to eq newlist
    end

    it 'new entry is inserted' do
      newlist = create(:ordered_list_entry, num_children: 2)
      expect(newlist).to receive(:increment_child_positions).with(1).and_call_original

      new_entry = create(:ordered_list_entry)
      newlist.insert(new_entry, 1)

      expect(newlist.child_at_position(1)).to eq new_entry
      expect(newlist.children.map(&:list_position)).to match_array([0, 1, 2])
    end
  end


  describe 'delete' do

    it 'does nothing if the entry is not in the list' do
      newlist = create(:ordered_list_entry, num_children: 2)
      not_in_list = create(:ordered_list_entry, name: 'not in the list')

      newlist.delete(not_in_list)
      expect(newlist.children.size).to eq 2
    end

    it 'deletes the entry from list' do
      newlist = create(:ordered_list_entry, num_children: 1)
      newlist.delete(newlist.children.first)
      expect(newlist.children).to be_empty
    end

    it 'calls decrement_child_positions starting with the position where the entry was' do
      newlist = create(:ordered_list_entry, num_children: 3)
      expect(newlist).to receive(:decrement_child_positions).with(2)
                             .and_call_original

      last_entry = newlist.children.last
      newlist.delete(last_entry)

      expect(newlist.children.size).to eq 2
      expect(newlist.children.map(&:list_position)).to match_array([0, 1])
    end
  end


  describe 'delete_child_at (deletes child at the zero-based position)' do

    it 'does nothing if no children' do
      no_children = create(:ordered_list_entry)

      expect(no_children).not_to receive(:delete)
      no_children.delete_child_at(0)
    end

    it 'does nothing if the position >= the number of children' do
      newlist = create(:ordered_list_entry, num_children: 2)
      expect(newlist.delete_child_at(2).size).to eq 2
    end

    it 'removes the entry at that position' do
      newlist = create(:ordered_list_entry, num_children: 3)

      expect(newlist).to receive(:decrement_child_positions).with(2).and_call_original

      newlist.delete_child_at(2)

      expect(newlist.children.size).to eq 2
      expect(newlist.children.map(&:list_position)).to match_array([0, 1])
    end

    it 'calls decrement_child_positions after entry deleted if entry was in the list_entry' do
      newlist = create(:ordered_list_entry, num_children: 3)

      expect(newlist).to receive(:decrement_child_positions).with(2).and_call_original

      newlist.delete_child_at(2)

      expect(newlist.children.size).to eq 2
      expect(newlist.children.map(&:list_position)).to match_array([0, 1])
    end

  end


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

    it 'default decrement starting position is the last position' do
      newlist = create(:ordered_list_entry, num_children: 3)

      expect(newlist).to receive(:decrement_child_positions).with(no_args)
                             .and_call_original

      original_positions = newlist.children.map(&:list_position)
      newlist.send(:decrement_child_positions)
      expect(newlist.children.map(&:list_position)).to match_array(original_positions)
    end

  end


  describe 'next_list_position' do
    it 'is the last position for children ( = children.size)' do
      expect(create(:ordered_list_entry, num_children: 2).next_list_position).to eq 2
    end

    it 'is zero if there are no children' do
      expect(create(:ordered_list_entry).next_list_position).to eq 0
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


  describe 'child_at_position' do

    it 'no children returns nil' do
      no_children = create(:ordered_list_entry)
      expect(no_children.child_at_position(0)).to be_nil
    end

    describe 'has children' do

      it 'no child at that position' do
        #two_children = create(:ordered_list_entry, num_children: 2)
        expect(two_children.child_at_position(5)).to be_nil
      end

      it 'returns the child at that position' do
        three_kids = create(:ordered_list_entry, num_children: 3)
        kid_two = create(:ordered_list_entry, name: 'kid 2')
        three_kids.insert(kid_two, 1)

        expect(three_kids.child_at_position(1)).to eq kid_two
      end
    end
  end


  describe 'allowable_as_parents' do

    it 'an emtpy list will just return that same empty list as allowed parents' do
      expect(create(:ordered_list_entry).allowable_as_parents).to be_empty
    end

    it 'self cannot be a parent' do
      new_entry = create(:ordered_list_entry)
      expect(new_entry.allowable_as_parents([new_entry])).to be_empty
    end

    it 'children cannot be a parent' do
      toplist = create(:ordered_list_entry, name: 'toplist', num_children: 3)
      not_a_child = create(:ordered_list_entry, name: 'not a child')

      expect(toplist.allowable_as_parents([toplist, not_a_child])).to match_array([not_a_child])
    end

    it 'if the entry has not been saved, is the list of potential parents given' do
      not_saved = build(:ordered_list_entry)
      toplist = create(:ordered_list_entry, name: 'toplist', num_children: 3)

      expect(not_saved.allowable_as_parents([])).to be_empty
      expect(not_saved.allowable_as_parents([toplist])).to eq [toplist]
    end
  end

end
