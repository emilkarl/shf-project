require 'rails_helper'


RSpec.describe OrderedListEntry, type: :model do

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




  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:ordered_list_entry)).to be_valid
      expect(create(:ordered_list_entry, name: 'new entry 1')).to be_valid
      expect(create(:ordered_list_entry, parent_name: 'new entry 1')).to be_valid
    end
  end


  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :list_position }
  end


  describe 'all_as_array_nested_by_name' do
    it "calls all_as_array with order: ['name']" do
      expect(described_class).to receive(:all_as_array).with(order: %w(  name))
      described_class.all_as_array_nested_by_name
    end
  end


  describe 'display_name_with_depth' do

    it "default prefix string is '-'" do
      expect(two_children.children.first.display_name_with_depth.first).to eq '-'
    end

    it 'can specify the prefix' do
      expect(two_children.children.first.display_name_with_depth(prefix: '@').first).to eq '@'
    end

    it 'prefix is repeated (depth) times and then a space and then the name' do
      grandchild_one =build(:ordered_list_entry, name: 'grandchild_one')
      child_one = two_children.children.first
      child_one.insert(grandchild_one)

      expect(grandchild_one.display_name_with_depth).to eq "-- grandchild_one"
    end
  end

end
