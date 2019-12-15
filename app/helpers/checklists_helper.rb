module ChecklistsHelper

  # These might be used for UserChecklist views.  Keeping this file in the repo for now.

include ChecklistCommonHelper

  TRUNCATE_LENGTH = 50

  def as_li_ordered_entry_item(checklist_item, li_classes: ['checklist-item'])
    tag.li(link_to("#{checklist_item.order_in_list}. #{checklist_item.name} - #{checklist_item.description.truncate(TRUNCATE_LENGTH)}", checklist_item_path(checklist_item)), { class: li_classes })
  end


  def as_li_ordered_entry_list(checklist_entry, li_classes: ['checklist-entry'])
    path_method = (checklist_entry.class.name.underscore + '_path').to_sym
    tag.li(link_to("#{checklist_entry.name}", send(path_method, checklist_entry)), { class: li_classes })
  end

end
