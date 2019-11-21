class AddChecklistItemsToChecklist < ActiveRecord::Migration[5.2]

  def change
    add_reference :checklist_items, :checklist, foreign_key: true
    add_column :checklist_items, :order_in_list, :integer
  end

end
