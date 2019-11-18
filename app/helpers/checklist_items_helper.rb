module ChecklistItemsHelper

  def date_completed_display(checklist_item)
    checklist_item.complete ? checklist_item.date_completed.to_s : ''
  end

end
