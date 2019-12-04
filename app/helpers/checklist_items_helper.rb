module ChecklistItemsHelper

  include ChecklistCommonHelper


  def as_li_ordered_entry_item(checklist_item, li_classes: ['checklist-item'])
    tag.li(link_to("#{checklist_item.order_in_list}. #{checklist_item.name} - #{checklist_item.description}", checklist_item_path(checklist_item)), { class: li_classes })
  end

end
