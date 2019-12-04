#--------------------------
#
# @class UserChecklist
#
# @desc Responsibility: A Checklist that a User has/has not completed.
#  This associates a Checklist to a User: it is a checklist that this user is or should be 'working on.'
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-11-27
#
#--------------------------
class UserChecklist < ApplicationRecord

  belongs_to :checklist
  belongs_to :user

  # TODO how does this relate to UserChecklistItems?  through User and checklist and UserchecklistItems and Checklist...

  def completed?
    return false if checklist.checklist_items.empty?
    #checklist.checklist_items.reduce(true) { |all_completed, item| all_completed && item.complete }
  end


  alias complete? completed?
  alias done? completed?


  def time_completed
    #checklist_items.map(&:date_completed).max
  end

end
