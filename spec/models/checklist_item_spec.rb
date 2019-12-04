require 'rails_helper'


RSpec.describe ChecklistItem do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:checklist_item)).to be_valid
    end
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :order_in_list }
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:checklist) }
  end
end
