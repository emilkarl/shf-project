# Steps for working with Checklists
#

And(/^the following checklists exist:$/) do |table|

  table.hashes.each do |checklist|
    name = checklist.delete('name') || ''
    description = checklist.delete('description') || ''

    new_checklist = FactoryBot.create(:checklist, name: name, description: description)

  end
end


# add entries to checklists. 'entries' might be ChecklistItems or other Checklists
And(/^these checklists have these entries:$/) do | checklist_entry |
  # FIXME - TBD
end
