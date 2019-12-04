require 'rails_helper'

RSpec.describe UserChecklistItem, type: :model do

  it 'Factories and traits are valid' do
    expect(build(:user_checklist_item)).to be_valid
    expect(build(:user_checklist_item, :completed)).to be_valid
    expect(build(:user_checklist_item, :not_completed)).to be_valid
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:checklist_item) }
    it { is_expected.to belong_to(:user) }
  end


  describe 'Scopes' do

    describe 'completed' do
      pending
    end

    describe 'not_completed' do
      pending
    end
  end

  describe 'completed?' do
    pending
  end

  describe 'complete' do
    pending
  end

end
