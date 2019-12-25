#--------------------------
#
# @class ChecklistManager
#
# @desc Responsibility: Creates UserChecklists on demand. Reports whether a user has completed a checklist.
# TODO I'm not sure where these responsibilities should go so I'm putting them here for now. As I develop and refine them,
# hopefully it'll be clear where the responsibilities should be
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   12/21/19
#
#--------------------------


class ChecklistManager

  # Given a checklist (e.g. OrderedListEntry), create a UserChecklist
  # for the user.  Copy all items in the original list so there is a
  # UserChecklist entry for every item, including all nested ones.
  #
  # @param [Array<OrderedListEntry>] list_of_entries - the original checklist to use as the bases for UserChecklist entry(-ies)
  # @param [User] user - the user this is for (who will/won't be completing the entry(-ies) in the UserChecklist)
  # @return [Array<UserChecklist>] - the ordered list of UserChecklist entries
  #
  def self.create_list_for_user(list_of_entries, user)

    # return an empty list if the arguments are empty or nil
    return [] if !orig_list_valid?(list_of_entries) || user.nil?

    list = []
    list_of_entries.each do |orig_entry|
      list.concat(create_checklist_entry_for_user(orig_entry, user) )
    end
    list
  end


  def self.create_checklist_entry_for_user(checklist_entry, user)
    list = []
    checklist_entry.children.each do | checklist_entry_child |
      list.concat(create_checklist_entry_for_user(checklist_entry_child, user) )
    end
    valid_list_position = checklist_entry.list_position.blank? ? 0 : checklist_entry.list_position
    list << UserChecklist.create(checklist: checklist_entry, user: user, list_position: valid_list_position)
    list
  end

  def self.orig_list_valid?(orig_list)
    if orig_list.nil? || !orig_list.respond_to?(:each) || orig_list.empty?
      false
    else
      true
    end
  end
end
