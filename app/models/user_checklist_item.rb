#--------------------------
#
# @class UserChecklistItem
#
# @desc Responsibility: A ChecklistItem that a User has/has not completed.
#  This associates a ChecklistItem to a User: it is a checklist item that this user is or should be 'working on.'
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-11-27
#
#--------------------------
class UserChecklistItem < ApplicationRecord

  belongs_to :checklist_item
  belongs_to :user

  scope :completed, -> { where('time_completed IS NOT NULL') }
  scope :not_completed, -> { where('time_completed IS NULL') }


  def completed?
    !time_completed.blank?
  end


  alias complete? completed?
  alias done? completed?


  def completed(time = Time.local.now)
    time_completed = time
  end

end
