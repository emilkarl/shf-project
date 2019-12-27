require 'ordered_ancestry_entry'

#--------------------------
#
# @class UserChecklist
#
# @desc Responsibility: track the status of a checklist item (an OrderedListEntry)
# for a particular User
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date  2019-12-04
#
#--------------------------
class UserChecklist < ApplicationRecord

  belongs_to :user
  belongs_to :checklist, class_name: "OrderedListEntry", foreign_key: "ordered_list_entry_id"

  accepts_nested_attributes_for :checklist


  has_ancestry

  include OrderedAncestryEntry

  # --------------------------------------------------------------------------


  def self.completed
    where.not(date_completed: nil)
  end


  def self.uncompleted
    where(date_completed: nil)
  end


  def self.completed_by_user(user)
    where(user: user).completed
  end


  def self.not_completed_by_user(user)
    where(user: user).uncompleted
  end


  # --------------------------------------------------------------------------

  def completed?
    !date_completed.blank? && descendants.inject(:true) { |is_completed, descendant| descendant.completed? && is_completed }
  end


  # @return [Array<UserChecklist>] - the list of all items that are completed, including self and children
  def completed
    all_complete = descendants.completed.to_a
    all_complete.prepend self unless date_completed.blank?
    all_complete
  end


  # @return [Array<UserChecklist>] - the list of all items that are not completed, including self and children
  def uncompleted
    all_uncomplete = descendants.uncompleted.to_a
    all_uncomplete.prepend self if date_completed.blank?
    all_uncomplete
  end
end
