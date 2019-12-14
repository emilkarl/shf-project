#--------------------------
#
# @class UserChecklist
#
# @desc Responsibility: track the status of a checklist item (an OrderedListEntry) for a particular User
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date  2019-12-04
#
# TODO what is the relationship between the children of the source checklist and children of this? (user- checklist items)
#
#--------------------------
class UserChecklist < ApplicationRecord

  belongs_to :user
  belongs_to :checklist, class_name: "OrderedListEntry", foreign_key: "ordered_list_entry_id"


  def complete?
    !date_completed.blank?
    # has children? how to know if nested user checklists are also complete?
  end

end
